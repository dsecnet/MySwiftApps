import Foundation

/// WebSocket Service for real-time communication during live sessions
class WebSocketService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var isConnected = false
    @Published var receivedMessages: [WSMessage] = []

    // MARK: - Private Properties

    private var webSocketTask: URLSessionWebSocketTask?
    private let sessionId: String
    private let baseURL = "ws://localhost:8000"  // WebSocket URL

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
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("❌ No auth token")
            return
        }

        // WebSocket URL with session ID
        let urlString = "\(baseURL)/api/v1/live-sessions/ws/\(sessionId)?token=\(token)"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid WebSocket URL")
            return
        }

        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()

        // Start receiving messages
        receiveMessage()

        print("✅ WebSocket connecting to session: \(sessionId)")
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        print("🔌 WebSocket disconnected")
    }

    // MARK: - Send Messages

    func sendMessage(_ message: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to serialize message")
            return
        }

        let message = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("❌ WebSocket send error: \(error)")
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
                print("❌ WebSocket receive error: \(error)")
                self.handleDisconnection()
            }
        }
    }

    private func handleMessage(text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            print("❌ Failed to parse message")
            return
        }

        print("📩 Received message type: \(type)")

        DispatchQueue.main.async {
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
                print("⚠️ Unknown message type: \(type)")
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
        print("🚀 Session started: \(sessionId)")
    }

    private func handleSessionEnd() {
        onSessionEnd?()
        print("🏁 Session ended")
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
        print("⚠️ Form correction for \(userId): \(message)")
    }

    private func handleParticipantJoined(_ json: [String: Any]) {
        guard let userName = json["user_name"] as? String else { return }

        onParticipantJoined?(userName)
        print("👋 Participant joined: \(userName)")
    }

    private func handleExerciseStart(_ json: [String: Any]) {
        guard let exerciseName = json["exercise_name"] as? String else { return }
        print("🏋️ Exercise started: \(exerciseName)")
    }

    private func handleExerciseComplete(_ json: [String: Any]) {
        guard let userId = json["user_id"] as? String else { return }
        print("✅ User \(userId) completed exercise")
    }

    // MARK: - Connection Management

    private func handleDisconnection() {
        isConnected = false

        // Attempt reconnection after 3 seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            print("🔄 Attempting to reconnect...")
            self.connect()
        }
    }
}

// MARK: - URLSessionWebSocketDelegate

extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.isConnected = true
            print("✅ WebSocket connected")
        }

        // Start heartbeat to keep connection alive
        startHeartbeat()
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.isConnected = false
            print("🔌 WebSocket closed with code: \(closeCode)")
        }
    }

    // MARK: - Heartbeat

    private func startHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self, self.isConnected else { return }
            self.sendHeartbeat()
        }
    }
}
