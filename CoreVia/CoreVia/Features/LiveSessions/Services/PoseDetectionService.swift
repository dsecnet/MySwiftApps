import Vision
import AVFoundation
import UIKit

/// Pose Detection Service using Apple Vision Framework
/// Detects body keypoints and calculates joint angles for form correction
class PoseDetectionService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var detectedPose: DetectedPose?
    @Published var formFeedback: FormFeedback?
    @Published var isDetecting = false

    // MARK: - Private Properties

    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let poseRequest = VNDetectHumanBodyPoseRequest()
    private let sequenceHandler = VNSequenceRequestHandler()

    private var currentExercise: ExerciseType = .squat

    // MARK: - Exercise Types

    enum ExerciseType {
        case squat
        case pushup
        case plank
        case lunges
        case bicepCurl
        case shoulderPress
    }

    // MARK: - Setup Camera

    func setupCamera() -> AVCaptureSession? {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("❌ Camera setup failed")
            return nil
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        // Rotate connection to portrait
        if let connection = videoOutput.connection(with: .video) {
            if #available(iOS 17.0, *) {
                connection.videoRotationAngle = 0
            } else {
                connection.videoOrientation = .portrait
            }
        }

        self.captureSession = session
        return session
    }

    func startDetection() {
        isDetecting = true
        captureSession?.startRunning()
    }

    func stopDetection() {
        isDetecting = false
        captureSession?.stopRunning()
    }

    func setExercise(_ exercise: ExerciseType) {
        currentExercise = exercise
    }

    // MARK: - Pose Detection

    private func detectPose(in image: CGImage) {
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])

        do {
            try requestHandler.perform([poseRequest])

            guard let observation = poseRequest.results?.first else { return }

            // Extract keypoints
            let keypoints = extractKeypoints(from: observation)

            // Calculate angles
            let angles = calculateAngles(from: keypoints)

            // Create detected pose
            let pose = DetectedPose(keypoints: keypoints, angles: angles)

            DispatchQueue.main.async {
                self.detectedPose = pose

                // Analyze form based on exercise
                self.formFeedback = self.analyzePoseForm(pose: pose, exercise: self.currentExercise)
            }

        } catch {
            print("❌ Pose detection error: \(error)")
        }
    }

    // MARK: - Extract Keypoints

    private func extractKeypoints(from observation: VNHumanBodyPoseObservation) -> [String: CGPoint] {
        var keypoints: [String: CGPoint] = [:]

        let jointNames: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck,
            .leftShoulder, .rightShoulder,
            .leftElbow, .rightElbow,
            .leftWrist, .rightWrist,
            .leftHip, .rightHip,
            .leftKnee, .rightKnee,
            .leftAnkle, .rightAnkle,
            .root
        ]

        for jointName in jointNames {
            if let point = try? observation.recognizedPoint(jointName),
               point.confidence > 0.3 {
                keypoints[jointName.rawValue.rawValue] = point.location
            }
        }

        return keypoints
    }

    // MARK: - Calculate Angles

    private func calculateAngles(from keypoints: [String: CGPoint]) -> [String: Double] {
        var angles: [String: Double] = [:]

        // Left Knee Angle (Hip-Knee-Ankle)
        if let hip = keypoints["left_hip_1"],
           let knee = keypoints["left_knee_1"],
           let ankle = keypoints["left_ankle_1"] {
            angles["left_knee"] = angle(from: hip, middle: knee, to: ankle)
        }

        // Right Knee Angle
        if let hip = keypoints["right_hip_1"],
           let knee = keypoints["right_knee_1"],
           let ankle = keypoints["right_ankle_1"] {
            angles["right_knee"] = angle(from: hip, middle: knee, to: ankle)
        }

        // Left Elbow Angle (Shoulder-Elbow-Wrist)
        if let shoulder = keypoints["left_shoulder_1"],
           let elbow = keypoints["left_elbow_1"],
           let wrist = keypoints["left_wrist_1"] {
            angles["left_elbow"] = angle(from: shoulder, middle: elbow, to: wrist)
        }

        // Right Elbow Angle
        if let shoulder = keypoints["right_shoulder_1"],
           let elbow = keypoints["right_elbow_1"],
           let wrist = keypoints["right_wrist_1"] {
            angles["right_elbow"] = angle(from: shoulder, middle: elbow, to: wrist)
        }

        // Hip Angle (Shoulder-Hip-Knee) - for squat depth
        if let shoulder = keypoints["left_shoulder_1"],
           let hip = keypoints["left_hip_1"],
           let knee = keypoints["left_knee_1"] {
            angles["left_hip"] = angle(from: shoulder, middle: hip, to: knee)
        }

        // Back Angle (vertical alignment)
        if let shoulder = keypoints["left_shoulder_1"],
           let hip = keypoints["left_hip_1"] {
            angles["back_vertical"] = verticalAngle(from: shoulder, to: hip)
        }

        return angles
    }

    // Calculate angle between three points
    private func angle(from p1: CGPoint, middle p2: CGPoint, to p3: CGPoint) -> Double {
        let v1 = CGVector(dx: p1.x - p2.x, dy: p1.y - p2.y)
        let v2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)

        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        var degrees = angle * 180 / .pi

        if degrees < 0 {
            degrees += 360
        }

        return degrees
    }

    // Calculate angle from vertical
    private func verticalAngle(from p1: CGPoint, to p2: CGPoint) -> Double {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let angle = atan2(dx, dy) * 180 / .pi
        return abs(angle)
    }

    // MARK: - Form Analysis

    private func analyzePoseForm(pose: DetectedPose, exercise: ExerciseType) -> FormFeedback {
        switch exercise {
        case .squat:
            return analyzeSquat(pose: pose)
        case .pushup:
            return analyzePushup(pose: pose)
        case .plank:
            return analyzePlank(pose: pose)
        case .lunges:
            return analyzeLunges(pose: pose)
        case .bicepCurl:
            return analyzeBicepCurl(pose: pose)
        case .shoulderPress:
            return analyzeShoulderPress(pose: pose)
        }
    }

    // MARK: - Squat Analysis

    private func analyzeSquat(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check knee angle (should be 80-100° at bottom)
        if let leftKnee = pose.angles["left_knee"] {
            if leftKnee < 70 {
                score -= 20
                corrections.append("Knee too bent - don't go too deep")
            } else if leftKnee > 110 {
                score -= 15
                corrections.append("Squat deeper - knees should reach 90°")
            }
        }

        // Check hip angle (should be ~90° at bottom)
        if let leftHip = pose.angles["left_hip"] {
            if leftHip < 80 || leftHip > 110 {
                score -= 15
                corrections.append("Keep hips aligned")
            }
        }

        // Check back angle (should be relatively vertical)
        if let backAngle = pose.angles["back_vertical"] {
            if backAngle > 30 {
                score -= 25
                corrections.append("Keep back straight - too much forward lean")
            }
        }

        // Check knee alignment (knees shouldn't go past toes)
        if let leftKnee = pose.keypoints["left_knee_1"],
           let leftAnkle = pose.keypoints["left_ankle_1"] {
            if leftKnee.x > leftAnkle.x + 0.1 {
                score -= 20
                corrections.append("Knees going past toes - push hips back")
            }
        }

        let message = corrections.isEmpty ? "Perfect form! ✅" : corrections.joined(separator: "\n")
        let correctionType = corrections.isEmpty ? nil : "squat_form"

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: correctionType,
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }

    // MARK: - Pushup Analysis

    private func analyzePushup(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check elbow angle (should be 45-90° during pushup)
        if let leftElbow = pose.angles["left_elbow"] {
            if leftElbow < 40 {
                score -= 20
                corrections.append("Go deeper - elbows should reach 90°")
            } else if leftElbow > 170 {
                score -= 10
                corrections.append("Fully extend arms at top")
            }
        }

        // Check body alignment (straight line from head to ankles)
        if let shoulder = pose.keypoints["left_shoulder_1"],
           let hip = pose.keypoints["left_hip_1"],
           let ankle = pose.keypoints["left_ankle_1"] {

            let shoulderHipDist = abs(shoulder.y - hip.y)
            let hipAnkleDist = abs(hip.y - ankle.y)

            if abs(shoulderHipDist - hipAnkleDist) > 0.15 {
                score -= 25
                corrections.append("Keep body straight - no sagging or piking")
            }
        }

        let message = corrections.isEmpty ? "Excellent form! 💪" : corrections.joined(separator: "\n")

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: corrections.isEmpty ? nil : "pushup_form",
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }

    // MARK: - Plank Analysis

    private func analyzePlank(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check body alignment (straight horizontal line)
        if let shoulder = pose.keypoints["left_shoulder_1"],
           let hip = pose.keypoints["left_hip_1"],
           let _ = pose.keypoints["left_ankle_1"] {

            // Check if body forms straight line
            let shoulderY = shoulder.y
            let hipY = hip.y

            if abs(hipY - shoulderY) > 0.1 {
                score -= 30
                corrections.append("Don't let hips sag - engage core")
            }

            if hipY < shoulderY - 0.05 {
                score -= 20
                corrections.append("Hips too high - lower them")
            }
        }

        // Check elbow position (should be under shoulders)
        if let shoulder = pose.keypoints["left_shoulder_1"],
           let elbow = pose.keypoints["left_elbow_1"] {
            if abs(shoulder.x - elbow.x) > 0.1 {
                score -= 15
                corrections.append("Elbows should be directly under shoulders")
            }
        }

        let message = corrections.isEmpty ? "Solid plank! 🔥" : corrections.joined(separator: "\n")

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: corrections.isEmpty ? nil : "plank_form",
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }

    // MARK: - Lunges Analysis

    private func analyzeLunges(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check front knee angle (should be ~90°)
        if let leftKnee = pose.angles["left_knee"] {
            if leftKnee < 80 || leftKnee > 110 {
                score -= 20
                corrections.append("Front knee should be at 90°")
            }
        }

        // Check if front knee goes past toes
        if let knee = pose.keypoints["left_knee_1"],
           let ankle = pose.keypoints["left_ankle_1"] {
            if knee.x > ankle.x + 0.1 {
                score -= 25
                corrections.append("Knee shouldn't go past toes")
            }
        }

        // Check torso (should be upright)
        if let backAngle = pose.angles["back_vertical"] {
            if backAngle > 20 {
                score -= 15
                corrections.append("Keep torso upright")
            }
        }

        let message = corrections.isEmpty ? "Perfect lunge! 👌" : corrections.joined(separator: "\n")

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: corrections.isEmpty ? nil : "lunge_form",
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }

    // MARK: - Bicep Curl Analysis

    private func analyzeBicepCurl(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check elbow angle (should be 30-160° during curl)
        if let leftElbow = pose.angles["left_elbow"] {
            if leftElbow < 25 {
                score -= 15
                corrections.append("Don't curl too high")
            } else if leftElbow > 170 {
                score -= 10
                corrections.append("Full extension at bottom")
            }
        }

        // Check elbow position (should stay stable, not moving forward/back)
        // This would require tracking elbow position over frames

        let message = corrections.isEmpty ? "Good curl! 💪" : corrections.joined(separator: "\n")

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: corrections.isEmpty ? nil : "bicep_curl_form",
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }

    // MARK: - Shoulder Press Analysis

    private func analyzeShoulderPress(pose: DetectedPose) -> FormFeedback {
        var score: Double = 100.0
        var corrections: [String] = []

        // Check elbow angle (should be 45-180° during press)
        if let leftElbow = pose.angles["left_elbow"] {
            if leftElbow < 40 {
                score -= 20
                corrections.append("Press higher - arms should be straight at top")
            }
        }

        // Check back angle (should be relatively straight)
        if let backAngle = pose.angles["back_vertical"] {
            if backAngle > 15 {
                score -= 20
                corrections.append("Don't lean back - keep core tight")
            }
        }

        let message = corrections.isEmpty ? "Excellent press! 🏋️" : corrections.joined(separator: "\n")

        return FormFeedback(
            formScore: max(score, 0),
            correctionType: corrections.isEmpty ? nil : "shoulder_press_form",
            correctionMessage: message,
            isCorrect: corrections.isEmpty
        )
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension PoseDetectionService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isDetecting,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        detectPose(in: cgImage)
    }
}

// MARK: - Supporting Models

struct DetectedPose {
    let keypoints: [String: CGPoint]
    let angles: [String: Double]
}

struct FormFeedback {
    let formScore: Double  // 0-100
    let correctionType: String?
    let correctionMessage: String
    let isCorrect: Bool
}
