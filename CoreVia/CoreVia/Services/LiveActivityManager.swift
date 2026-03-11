//
//  LiveActivityManager.swift
//  CoreVia
//
//  Manages Live Activity lifecycle for GPS tracking
//

import Foundation
import ActivityKit
import os.log

@available(iOS 16.2, *)
class LiveActivityManager {

    static let shared = LiveActivityManager()

    private var currentActivity: Activity<CoreViaTrackingAttributes>?
    private let logger = Logger(subsystem: "az.fitness.CoreVia", category: "LiveActivity")

    private init() {}

    // MARK: - Start

    func startLiveActivity(activityType: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            logger.warning("Live Activities are not enabled by user")
            return
        }

        // End any existing activity first
        endLiveActivity()

        let attributes = CoreViaTrackingAttributes(
            activityType: activityType,
            startTime: Date()
        )

        let initialState = CoreViaTrackingAttributes.ContentState(
            distance: 0,
            duration: 0,
            calories: 0,
            speed: 0,
            steps: 0,
            isPaused: false,
            timerStartDate: Date()
        )

        let content = ActivityContent(state: initialState, staleDate: nil)

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            logger.info("Live Activity started")
        } catch {
            logger.error("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    // MARK: - Update

    func updateLiveActivity(
        distance: Double,
        duration: Int,
        calories: Int,
        speed: Double,
        steps: Int,
        isPaused: Bool
    ) {
        guard let activity = currentActivity else { return }

        // timerStartDate = now - elapsed seconds → Text(timerInterval:) counts up from there
        let timerStartDate = isPaused ? Date() : Date().addingTimeInterval(-Double(duration))

        let updatedState = CoreViaTrackingAttributes.ContentState(
            distance: distance,
            duration: duration,
            calories: calories,
            speed: speed,
            steps: steps,
            isPaused: isPaused,
            timerStartDate: timerStartDate
        )

        let content = ActivityContent(state: updatedState, staleDate: nil)

        Task {
            await activity.update(content)
        }
    }

    // MARK: - End

    func endLiveActivity() {
        guard let activity = currentActivity else { return }

        let finalState = activity.content.state
        let content = ActivityContent(state: finalState, staleDate: nil)

        Task {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        logger.info("Live Activity ended")
    }

    // MARK: - Status

    var isActive: Bool {
        currentActivity != nil
    }
}
