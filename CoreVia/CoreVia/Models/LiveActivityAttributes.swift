//
//  LiveActivityAttributes.swift
//  CoreVia
//
//  Shared model for Live Activity - used by both main app and widget extension
//

import Foundation
import ActivityKit

struct CoreViaTrackingAttributes: ActivityAttributes {

    /// Dynamic state that updates during the activity
    public struct ContentState: Codable, Hashable {
        var distance: Double      // km
        var duration: Int         // seconds
        var calories: Int
        var speed: Double         // km/h
        var steps: Int
        var isPaused: Bool
        var timerStartDate: Date  // Date() - duration, for Text(timerInterval:) auto-counting
    }

    /// Static info set when activity starts
    var activityType: String  // walking, running, cycling
    var startTime: Date
}
