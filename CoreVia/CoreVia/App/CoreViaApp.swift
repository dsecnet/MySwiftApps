

import SwiftUI

@main
struct CoreViaApp: App {

    // MARK: - App State
    // Global state-lər burda olacaq (gələcək)

    @State private var showJailbreakAlert = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    if JailbreakDetection.isJailbroken {
                        showJailbreakAlert = true
                    }
                }
                .alert("Security Warning", isPresented: $showJailbreakAlert) {
                    Button("I Understand", role: .cancel) { }
                } message: {
                    Text("This device appears to be jailbroken. Your data security may be compromised. Please use the app with caution.")
                }
        }
    }
}
