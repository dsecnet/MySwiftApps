import Foundation
import AuthenticationServices
import SwiftUI

// MARK: - Payment Response Models

struct PaymentCreateResponse: Codable {
    let paymentId: String
    let kapitalOrderId: Int
    let redirectUrl: String
    let amount: Double
    let currency: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case kapitalOrderId = "kapital_order_id"
        case redirectUrl = "redirect_url"
        case amount, currency, status
    }
}

struct PaymentStatusResponse: Codable {
    let paymentId: String
    let kapitalOrderId: Int
    let productId: String
    let planType: String
    let amount: Double
    let currency: String
    let status: String
    let isPaid: Bool
    let createdAt: Date
    let paidAt: Date?

    enum CodingKeys: String, CodingKey {
        case paymentId = "payment_id"
        case kapitalOrderId = "kapital_order_id"
        case productId = "product_id"
        case planType = "plan_type"
        case amount, currency, status
        case isPaid = "is_paid"
        case createdAt = "created_at"
        case paidAt = "paid_at"
    }
}

// MARK: - Kapital Payment Manager

@MainActor
class KapitalPaymentManager: ObservableObject {
    static let shared = KapitalPaymentManager()

    @Published var isProcessing = false
    @Published var currentPaymentId: String?
    @Published var paymentError: String?
    @Published var paymentSuccess = false

    private init() {}

    /// Backend-dən ödəniş sifarişi yaradır və bank URL-ini qaytarır
    func createOrder(productId: String) async throws -> PaymentCreateResponse {
        isProcessing = true
        paymentError = nil
        paymentSuccess = false

        do {
            let response: PaymentCreateResponse = try await APIService.shared.request(
                endpoint: "/api/v1/payment/create-order",
                method: "POST",
                body: ["product_id": productId]
            )

            currentPaymentId = response.paymentId
            return response
        } catch {
            isProcessing = false
            paymentError = error.localizedDescription
            throw error
        }
    }

    /// Ödəniş statusunu yoxlayır
    func checkPaymentStatus(paymentId: String) async throws -> PaymentStatusResponse {
        let response: PaymentStatusResponse = try await APIService.shared.request(
            endpoint: "/api/v1/payment/status/\(paymentId)",
            method: "GET"
        )

        if response.isPaid {
            paymentSuccess = true
            isProcessing = false

            // User məlumatlarını yenilə ki premium status backend-dən gəlsin
            await AuthManager.shared.fetchCurrentUser()
        }

        return response
    }

    /// Ödəniş tamamlandıqdan sonra statusu yoxla (polling)
    func waitForPaymentCompletion(paymentId: String, maxAttempts: Int = 10) async -> Bool {
        for _ in 0..<maxAttempts {
            do {
                let status = try await checkPaymentStatus(paymentId: paymentId)
                if status.isPaid {
                    return true
                }
                if status.status == "Declined" || status.status == "Cancelled" {
                    paymentError = "Ödəniş ləğv edildi"
                    isProcessing = false
                    return false
                }
            } catch {
                // Sorğu xətası — davam et
            }

            // 2 saniyə gözlə
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }

        isProcessing = false
        paymentError = "Ödəniş statusu müəyyən edilə bilmədi"
        return false
    }

    /// Sıfırla
    func reset() {
        isProcessing = false
        currentPaymentId = nil
        paymentError = nil
        paymentSuccess = false
    }
}

// MARK: - Payment WebView (Safari açır)

struct PaymentWebView: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> SFSafariViewControllerWrapper {
        let wrapper = SFSafariViewControllerWrapper(url: url)
        wrapper.onDismiss = onDismiss
        return wrapper
    }

    func updateUIViewController(_ uiViewController: SFSafariViewControllerWrapper, context: Context) {}
}

class SFSafariViewControllerWrapper: UIViewController {
    let url: URL
    var onDismiss: (() -> Void)?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // SFSafariViewController istifadə edirik
        // Bu Apple-ın icazə verdiyi xarici ödəniş üsuludur
        if presentedViewController == nil {
            let safariVC = SafariPaymentController(url: url)
            safariVC.onDismiss = { [weak self] in
                self?.onDismiss?()
            }
            safariVC.modalPresentationStyle = .pageSheet
            present(safariVC, animated: true)
        }
    }
}

import SafariServices

class SafariPaymentController: SFSafariViewController, SFSafariViewControllerDelegate {
    var onDismiss: (() -> Void)?

    convenience init(url: URL) {
        self.init(url: url, configuration: .init())
        self.delegate = self
        self.preferredControlTintColor = UIColor(red: 233/255, green: 55/255, blue: 40/255, alpha: 1)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        onDismiss?()
    }
}
