import SwiftUI
import AVFoundation

/// Live Workout View with Real-time Pose Detection
struct LiveWorkoutView: View {
    let sessionId: String

    @StateObject private var poseDetection = PoseDetectionService()
    @StateObject private var webSocket: WebSocketService
    @ObservedObject private var loc = LocalizationManager.shared

    @State private var currentExerciseIndex = 0
    @State private var repCount = 0
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var formScore: Double = 100

    @Environment(\.dismiss) var dismiss

    init(sessionId: String) {
        self.sessionId = sessionId
        _webSocket = StateObject(wrappedValue: WebSocketService(sessionId: sessionId))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView

                // Camera View with Overlay
                GeometryReader { geometry in
                    ZStack {
                        // Camera Preview
                        CameraPreviewView(session: poseDetection.setupCamera() ?? AVCaptureSession())
                            .frame(width: geometry.size.width, height: geometry.size.height)

                        // Pose Overlay (skeleton visualization)
                        if let pose = poseDetection.detectedPose {
                            PoseOverlayView(pose: pose, frameSize: geometry.size)
                        }

                        // Form Feedback Overlay
                        if let feedback = poseDetection.formFeedback {
                            VStack {
                                Spacer()

                                FormFeedbackView(feedback: feedback)
                                    .padding()
                                    .transition(.move(edge: .bottom))
                            }
                        }

                        // Exercise Info Overlay
                        VStack {
                            exerciseInfoView
                                .padding()

                            Spacer()
                        }
                    }
                }

                // Bottom Controls
                controlsView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startWorkout()
        }
        .onDisappear {
            endWorkout()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()

            // Connection Status
            HStack(spacing: 8) {
                Circle()
                    .fill(webSocket.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(webSocket.isConnected ? "Live" : "Connecting...")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Exercise Info

    private var exerciseInfoView: some View {
        VStack(spacing: 8) {
            // Exercise Name
            Text("Squats")  // TODO: Dynamic from session exercises
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Rep Counter
            Text("\(repCount) reps")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            // Form Score
            HStack(spacing: 8) {
                Text("Form:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                Text("\(Int(formScore))%")
                    .font(.headline)
                    .foregroundColor(formScoreColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.6))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
    }

    private var formScoreColor: Color {
        if formScore >= 80 {
            return .green
        } else if formScore >= 60 {
            return .orange
        } else {
            return .red
        }
    }

    // MARK: - Controls

    private var controlsView: some View {
        HStack(spacing: 20) {
            // Pause Button
            Button {
                // TODO: Pause workout
            } label: {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }

            Spacer()

            // Next Exercise
            Button {
                nextExercise()
            } label: {
                HStack(spacing: 8) {
                    Text("Next Exercise")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color("PrimaryColor"))
                .cornerRadius(25)
            }

            Spacer()

            // End Workout
            Button {
                endWorkout()
                dismiss()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }

    // MARK: - Actions

    private func startWorkout() {
        // Connect WebSocket
        webSocket.connect()

        // Setup callbacks
        webSocket.onFormCorrection = { correction in
            feedbackMessage = correction.message
            formScore = correction.formScore
            showFeedback = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showFeedback = false
            }
        }

        // Start pose detection
        poseDetection.setExercise(.squat)
        poseDetection.startDetection()

        // Monitor form feedback
        _ = poseDetection.$formFeedback.sink { feedback in
            if let feedback = feedback {
                formScore = feedback.formScore

                // Send to backend if correction needed
                if !feedback.isCorrect {
                    let userId = UserDefaults.standard.string(forKey: "userId") ?? ""
                    webSocket.sendFormUpdate(
                        userId: userId,
                        correction: feedback.correctionMessage,
                        score: feedback.formScore
                    )
                }
            }
        }
    }

    private func endWorkout() {
        poseDetection.stopDetection()
        webSocket.disconnect()
    }

    private func nextExercise() {
        currentExerciseIndex += 1
        repCount = 0

        // TODO: Change exercise type based on session exercises
        // poseDetection.setExercise(.pushup)
    }
}

// MARK: - Camera Preview View

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        DispatchQueue.main.async {
            previewLayer.frame = view.bounds
        }

        session.startRunning()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Pose Overlay View (Skeleton)

struct PoseOverlayView: View {
    let pose: DetectedPose
    let frameSize: CGSize

    var body: some View {
        Canvas { context, size in
            // Draw skeleton connections
            drawSkeleton(context: context, size: size)

            // Draw keypoints
            for (_, point) in pose.keypoints {
                let scaledPoint = scalePoint(point, to: size)

                context.fill(
                    Circle()
                        .path(in: CGRect(
                            x: scaledPoint.x - 5,
                            y: scaledPoint.y - 5,
                            width: 10,
                            height: 10
                        )),
                    with: .color(.green)
                )
            }
        }
    }

    private func drawSkeleton(context: GraphicsContext, size: CGSize) {
        let connections: [(String, String)] = [
            ("left_shoulder_1", "left_elbow_1"),
            ("left_elbow_1", "left_wrist_1"),
            ("right_shoulder_1", "right_elbow_1"),
            ("right_elbow_1", "right_wrist_1"),
            ("left_shoulder_1", "left_hip_1"),
            ("right_shoulder_1", "right_hip_1"),
            ("left_hip_1", "right_hip_1"),
            ("left_hip_1", "left_knee_1"),
            ("left_knee_1", "left_ankle_1"),
            ("right_hip_1", "right_knee_1"),
            ("right_knee_1", "right_ankle_1"),
        ]

        for (start, end) in connections {
            if let startPoint = pose.keypoints[start],
               let endPoint = pose.keypoints[end] {
                let scaledStart = scalePoint(startPoint, to: size)
                let scaledEnd = scalePoint(endPoint, to: size)

                var path = Path()
                path.move(to: scaledStart)
                path.addLine(to: scaledEnd)

                context.stroke(
                    path,
                    with: .color(.green),
                    lineWidth: 3
                )
            }
        }
    }

    private func scalePoint(_ point: CGPoint, to size: CGSize) -> CGPoint {
        return CGPoint(
            x: point.x * size.width,
            y: (1 - point.y) * size.height  // Flip Y coordinate
        )
    }
}

// MARK: - Form Feedback View

struct FormFeedbackView: View {
    let feedback: FormFeedback

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: feedback.isCorrect ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(feedback.isCorrect ? .green : .orange)

            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text(feedback.isCorrect ? "Perfect Form!" : "Form Correction")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(feedback.correctionMessage)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            // Score
            Text("\(Int(feedback.formScore))%")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            feedback.isCorrect ?
                Color.green.opacity(0.9) :
                Color.orange.opacity(0.9)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// #Preview { // iOS 17+ only
//     LiveWorkoutView(sessionId: "123")
// }
