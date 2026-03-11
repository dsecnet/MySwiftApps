//
//  CoreViaWidgetExtensionBundle.swift
//  CoreViaWidgetExtension
//
//  Widget extension entry point for Live Activity
//

import WidgetKit
import SwiftUI

@main
struct CoreViaWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        CoreViaLiveActivity()
    }
}
