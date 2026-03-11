

import SwiftUI

@main
struct CoreViaApp: App {

    // MARK: - App State
    // Global state-lər burda olacaq (gələcək)

    @State private var showJailbreakAlert = false

    private func handleDeepLink(_ url: URL) {
        // corevia://payment?status=success&payment_id=xxx
        guard url.scheme == "corevia", url.host == "payment" else { return }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let status = components?.queryItems?.first(where: { $0.name == "status" })?.value
        let paymentId = components?.queryItems?.first(where: { $0.name == "payment_id" })?.value

        if status == "success", let paymentId = paymentId {
            Task {
                _ = await KapitalPaymentManager.shared.waitForPaymentCompletion(paymentId: paymentId)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    if JailbreakDetection.isJailbroken {
                        showJailbreakAlert = true
                    }
                }
                .alert(LocalizationManager.shared.localized("jailbreak_title"), isPresented: $showJailbreakAlert) {
                    Button(LocalizationManager.shared.localized("jailbreak_understood"), role: .cancel) { }
                } message: {
                    Text(LocalizationManager.shared.localized("jailbreak_message"))
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
}
