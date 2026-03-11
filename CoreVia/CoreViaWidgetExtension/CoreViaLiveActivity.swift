//
//  CoreViaLiveActivity.swift
//  CoreViaWidgetExtension
//
//  Live Activity UI - Lock Screen banner + Dynamic Island
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

struct CoreViaLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CoreViaTrackingAttributes.self) { context in
            // LOCK SCREEN BANNER
            LockScreenBannerView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // EXPANDED Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label {
                            Text(formatDistance(context.state.distance))
                                .font(.system(size: 16, weight: .bold))
                        } icon: {
                            Image(systemName: "figure.run")
                                .foregroundColor(.green)
                        }

                        Label {
                            Text("\(context.state.steps)")
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "shoeprints.fill")
                                .foregroundColor(.cyan)
                                .font(.system(size: 10))
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Label {
                            if context.state.isPaused {
                                Text(formatDuration(context.state.duration))
                                    .font(.system(size: 16, weight: .bold))
                            } else {
                                Text(timerInterval: context.state.timerStartDate...Date.distantFuture, countsDown: false)
                                    .font(.system(size: 16, weight: .bold))
                                    .monospacedDigit()
                            }
                        } icon: {
                            Image(systemName: "timer")
                                .foregroundColor(.orange)
                        }

                        Label {
                            Text("\(context.state.calories) kcal")
                                .font(.system(size: 13))
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 10))
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(.purple)
                            .font(.system(size: 12))
                        Text(String(format: "%.1f km/h", context.state.speed))
                            .font(.system(size: 13, weight: .medium))

                        Spacer()

                        if context.state.isPaused {
                            HStack(spacing: 4) {
                                Image(systemName: "pause.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 10))
                                Text("Paused")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 6, height: 6)
                                Text("Tracking")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.top, 4)
                }

            } compactLeading: {
                // COMPACT - Leading
                HStack(spacing: 4) {
                    Image(systemName: activityIcon(context.attributes.activityType))
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text(formatDistance(context.state.distance))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                }
            } compactTrailing: {
                // COMPACT - Trailing (real-time timer)
                if context.state.isPaused {
                    Text(formatDuration(context.state.duration))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.orange)
                } else {
                    Text(timerInterval: context.state.timerStartDate...Date.distantFuture, countsDown: false)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.orange)
                        .monospacedDigit()
                }
            } minimal: {
                // MINIMAL
                Image(systemName: activityIcon(context.attributes.activityType))
                    .foregroundColor(.green)
                    .font(.system(size: 12))
            }
        }
    }
}

// MARK: - Lock Screen Banner View

struct LockScreenBannerView: View {
    let context: ActivityViewContext<CoreViaTrackingAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: activityIcon(context.attributes.activityType))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)

                Text("CoreVia")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if context.state.isPaused {
                    HStack(spacing: 4) {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 10))
                        Text("Paused")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 6, height: 6)
                        Text("Live")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Capsule())
                }
            }

            // Stats Grid
            HStack(spacing: 16) {
                // Distance
                StatColumn(
                    icon: "figure.run",
                    iconColor: .blue,
                    value: formatDistance(context.state.distance),
                    label: "km"
                )

                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.3))

                // Time (real-time timer)
                VStack(spacing: 4) {
                    Image(systemName: "timer")
                        .foregroundColor(.green)
                        .font(.system(size: 14))

                    if context.state.isPaused {
                        Text(formatDuration(context.state.duration))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    } else {
                        Text(timerInterval: context.state.timerStartDate...Date.distantFuture, countsDown: false)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .monospacedDigit()
                    }

                    Text("time")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.3))

                // Calories
                StatColumn(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(context.state.calories)",
                    label: "kcal"
                )

                Divider()
                    .frame(height: 36)
                    .background(Color.white.opacity(0.3))

                // Speed
                StatColumn(
                    icon: "speedometer",
                    iconColor: .purple,
                    value: String(format: "%.1f", context.state.speed),
                    label: "km/h"
                )
            }

            // Steps row
            HStack {
                Image(systemName: "shoeprints.fill")
                    .foregroundColor(.cyan)
                    .font(.system(size: 12))
                Text("\(context.state.steps) steps")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.15, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Stat Column

struct StatColumn: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 14))

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers

private func formatDistance(_ km: Double) -> String {
    if km < 1.0 {
        return String(format: "%.0fm", km * 1000)
    }
    return String(format: "%.2f", km)
}

private func formatDuration(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60

    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    }
    return String(format: "%d:%02d", minutes, secs)
}

private func activityIcon(_ type: String) -> String {
    switch type.lowercased() {
    case "running":
        return "figure.run"
    case "cycling":
        return "figure.outdoor.cycle"
    case "hiking":
        return "figure.hiking"
    default:
        return "figure.walk"
    }
}
