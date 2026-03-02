import Foundation
import os.log

/// WebSocket Service for real-time communication during live sessions
class WebSocketService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var isConnected = false
    @Published var receivedMessages: [WSMessage] = []

    // MARK: - Config
    private enum Config {
        static let heartbeatInterval: TimeInterval = 30
        static let reconnectDelay: TimeInterval = 3
    }

    // MARK: - Private Properties

    private var webSocketTask: URLSessionWebSocketTask?
    private var heartbeatTimer: Timer?
    private let sessionId: String

    // APIService baseURL-dan WebSocket URL-i yarat
    private var baseURL: String {
        let httpURL = APIService.shared.baseURL
        if httpURL.hasPrefix("https://") {
            return httpURL.replacingOccurrences(of: "https://", with: "wss://")
        } else {
            return httpURL.replacingOccurrences(of: "http://", with: "ws://")
        }
    }

    // MARK: - Callbacks

    var onFormCorrection: ((FormCorrectionMessage) -> Void)?
    var onSessionStart: ((SessionStartMessage) -> Void)?
    var onSessionEnd: (() -> Void)?
    var onParticipantJoined: ((String) -> Void)?

    // MARK: - Initialization

    init(sessionId: String) {
        self.sessionId = sessionId
        super.init()
    }

    // MARK: - Connection

    func connect() {
        guard let token = KeychainManager.shared.accessToken else {
            AppLogger.websocket.error("No auth token")
            return
        }

        // WebSocket URL with session ID (token Authorization header-də göndərilir, URL-də yox)
        let urlString = "\(baseURL)/api/v1/live-sessions/ws/\(sessionId)"
        guard let url = URL(string: urlString) else {
            AppLogger.websocket.error("Invalid WebSocket URL")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()

        // Start receiving messages
        receiveMessage()

        AppLogger.websocket.info("WebSocket connecting to session: \(self.sessionId)")
    }

    func disconnect() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        AppLogger.websocket.info("WebSocket disconnected")
    }

    // MARK: - Send Messages

    func sendMessage(_ message: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            AppLogger.websocket.error("Failed to serialize message")
            return
        }

        let message = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(message) { error in
            if let error = error {
                AppLogger.websocket.error("WebSocket send error: \(error.localizedDescription)")
            }
        }
    }

    func sendFormUpdate(userId: String, correction: String, score: Double) {
        let message: [String: Any] = [
            "type": "form_update",
            "user_id": userId,
            "correction": correction,
            "score": score,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendMessage(message)
    }

    func sendExerciseComplete(userId: String, exerciseId: String) {
        let message: [String: Any] = [
            "type": "exercise_complete",
            "user_id": userId,
            "exercise_id": exerciseId,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendMessage(message)
    }

    func sendHeartbeat() {
        let message: [String: Any] = [
            "type": "heartbeat",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        sendMessage(message)
    }

    // MARK: - Receive Messages

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text: text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text: text)
                    }
                @unknown default:
                    break
                }

                // Continue receiving
                self.receiveMessage()

            case .failure(let error):
                AppLogger.websocket.error("WebSocket receive error: \(error.localizedDescription)")
                self.handleDisconnection()
            }
        }
    }

    private func handleMessage(text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            AppLogger.websocket.error("Failed to parse message")
            return
        }

        AppLogger.websocket.debug("Received message type: \(type)")

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch type {
            case "session_start":
                self.handleSessionStart(json)

            case "session_end":
                self.handleSessionEnd()

            case "form_correction":
                self.handleFormCorrection(json)

            case "participant_joined":
                self.handleParticipantJoined(json)

            case "exercise_start":
                self.handleExerciseStart(json)

            case "exercise_complete":
                self.handleExerciseComplete(json)

            default:
                AppLogger.websocket.warning("Unknown message type: \(type)")
            }
        }
    }

    // MARK: - Message Handlers

    private func handleSessionStart(_ json: [String: Any]) {
        guard let sessionId = json["session_id"] as? String,
              let timestampString = json["timestamp"] as? String,
              let timestamp = ISO8601DateFormatter().date(from: timestampString) else { return }

        let message = SessionStartMessage(
            type: "session_start",
            sessionId: sessionId,
            timestamp: timestamp
        )

        onSessionStart?(message)
        AppLogger.websocket.info("Session started: \(sessionId)")
    }

    private func handleSessionEnd() {
        onSessionEnd?()
        AppLogger.websocket.info("Session ended")
    }

    private func handleFormCorrection(_ json: [String: Any]) {
        guard let userId = json["user_id"] as? String,
              let correctionType = json["correction_type"] as? String,
              let message = json["message"] as? String,
              let formScore = json["form_score"] as? Double else { return }

        let correction = FormCorrectionMessage(
            type: "form_correction",
            userId: userId,
            correctionType: correctionType,
            message: message,
            formScore: formScore
        )

        onFormCorrection?(correction)
        AppLogger.websocket.warning("Form correction for \(userId): \(message)")
    }

    private func handleParticipantJoined(_ json: [String: Any]) {
        guard let userName = json["user_name"] as? String else { return }

        onParticipantJoined?(userName)
        AppLogger.websocket.info("Participant joined: \(userName)")
    }

    private func handleExerciseStart(_ json: [String: Any]) {
        guard let exerciseName = json["exercise_name"] as? String else { return }
        AppLogger.websocket.debug("Exercise started: \(exerciseName)")
    }

    private func handleExerciseComplete(_ json: [String: Any]) {
        guard let userId = json["user_id"] as? String else { return }
        AppLogger.websocket.info("User \(userId) completed exercise")
    }

    // MARK: - Connection Management

    private func handleDisconnection() {
        isConnected = false

        // Attempt reconnection
        DispatchQueue.global().asyncAfter(deadline: .now() + Config.reconnectDelay) { [weak self] in
            guard let self = self else { return }
            AppLogger.websocket.info("Attempting to reconnect...")
            self.connect()
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = true
            AppLogger.websocket.info("WebSocket connected")
        }

        // Start heartbeat to keep connection alive
        startHeartbeat()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = false
            AppLogger.websocket.info("WebSocket closed with code: \(closeCode.rawValue)")
        }
    }

    // MARK: - Heartbeat

    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: Config.heartbeatInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isConnected else { return }
            self.sendHeartbeat()
        }
    }
}
