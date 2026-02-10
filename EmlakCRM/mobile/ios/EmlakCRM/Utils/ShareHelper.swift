import SwiftUI
import UIKit

struct ShareHelper {
    // Share property details
    static func shareProperty(_ property: Property) -> String {
        var text = "🏢 \(property.title)\n\n"

        text += "💰 Qiymət: \(property.price.toCurrency())\n"
        text += "📍 Ünvan: \(property.address ?? property.city)\n"

        if let area = property.areaSqm {
            text += "📐 Sahə: \(area.toArea())\n"
        }

        if let rooms = property.rooms {
            text += "🛏 Otaq: \(rooms)\n"
        }

        if let bathrooms = property.bathrooms {
            text += "🚿 Hamam: \(bathrooms)\n"
        }

        text += "🏷 Növ: \(property.propertyType.displayName)\n"
        text += "💼 \(property.dealType.displayName)\n"

        if let description = property.description {
            text += "\n📝 \(description)\n"
        }

        text += "\n📱 EmlakCRM ilə paylaşıldı"

        return text
    }

    // Share client details
    static func shareClient(_ client: Client) -> String {
        var text = "👤 \(client.name)\n\n"

        if let email = client.email {
            text += "✉️ Email: \(email)\n"
        }

        if let phone = client.phone {
            text += "📞 Telefon: \(phone)\n"
        }

        text += "🏷 Növ: \(client.clientType.displayName)\n"
        text += "📊 Status: \(client.status.displayName)\n"
        text += "📍 Mənbə: \(client.source.displayName)\n"

        if let notes = client.notes {
            text += "\n📝 Qeydlər: \(notes)\n"
        }

        text += "\n📱 EmlakCRM ilə paylaşıldı"

        return text
    }

    // Share deal details
    static func shareDeal(_ deal: Deal) -> String {
        var text = "💼 Sövdələşmə\n\n"

        text += "💰 Məbləğ: \(deal.agreedPrice.toCurrency())\n"
        text += "📊 Status: \(deal.status.displayName)\n"
        text += "📅 Tarix: \(deal.createdAt.toFormattedString())\n"

        if let notes = deal.notes {
            text += "\n📝 Qeydlər: \(notes)\n"
        }

        text += "\n📱 EmlakCRM ilə paylaşıldı"

        return text
    }

    // Share activity details
    static func shareActivity(_ activity: Activity) -> String {
        var text = "📅 \(activity.title)\n\n"

        text += "🏷 Növ: \(activity.activityType.displayName)\n"

        if let description = activity.description {
            text += "📝 \(description)\n\n"
        }

        if let scheduledAt = activity.scheduledAt {
            text += "⏰ Planlaşdırılıb: \(scheduledAt.toFullString())\n"
        }

        if let completedAt = activity.completedAt {
            text += "✅ Tamamlandı: \(completedAt.toFullString())\n"
        } else {
            text += "⏳ Status: Gözləyir\n"
        }

        text += "\n📱 EmlakCRM ilə paylaşıldı"

        return text
    }

    // Present share sheet
    static func presentShareSheet(text: String, from viewController: UIViewController? = nil) {
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        // For iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController?.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        // Get the top view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let topController = windowScene.windows.first?.rootViewController {
            var presented = topController
            while let next = presented.presentedViewController {
                presented = next
            }
            presented.present(activityVC, animated: true)
        }
    }
}

// SwiftUI wrapper for share functionality
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// View extension for easy sharing
extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        sheet(isPresented: isPresented) {
            ShareSheet(activityItems: items)
        }
    }
}
