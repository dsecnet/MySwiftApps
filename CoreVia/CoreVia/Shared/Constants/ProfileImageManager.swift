//
//  ProfileImageManager.swift
//  CoreVia
//
//  Profil şəkillərini local storage-də saxlama
//  UserDefaults ilə Base64 encoding
//

import SwiftUI
import UIKit

class ProfileImageManager: ObservableObject {
    
    static let shared = ProfileImageManager()
    
    @Published var profileImage: UIImage?
    
    private let imageKey = "user_profile_image"
    
    init() {
        loadImage()
    }
    
    // MARK: - Save Image
    func saveImage(_ image: UIImage) {
        // Şəkili compress et (300x300 max)
        guard let resizedImage = resizeImage(image, targetSize: CGSize(width: 300, height: 300)) else {
            print("❌ Şəkili resize edə bilmədi")
            return
        }
        
        // JPEG formatında convert et (80% quality)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            print("❌ Şəkili data-ya çevirə bilmədi")
            return
        }
        
        // Base64 string-ə çevir
        let base64String = imageData.base64EncodedString()
        
        // UserDefaults-a saxla
        UserDefaults.standard.set(base64String, forKey: imageKey)
        
        // Published property-ni yenilə
        DispatchQueue.main.async {
            self.profileImage = resizedImage
        }
        
        print("✅ Profil şəkli saxlanıldı: \(imageData.count) bytes")
    }
    
    // MARK: - Load Image
    func loadImage() {
        guard let base64String = UserDefaults.standard.string(forKey: imageKey) else {
            print("ℹ️ Saxlanılmış profil şəkli yoxdur")
            return
        }
        
        // Base64-dən Data-ya çevir
        guard let imageData = Data(base64Encoded: base64String) else {
            print("❌ Base64 decode edilə bilmədi")
            return
        }
        
        // Data-dan UIImage yarat
        guard let image = UIImage(data: imageData) else {
            print("❌ UIImage yaradıla bilmədi")
            return
        }
        
        DispatchQueue.main.async {
            self.profileImage = image
        }
        
        print("✅ Profil şəkli yükləndi")
    }
    
    // MARK: - Delete Image
    func deleteImage() {
        UserDefaults.standard.removeObject(forKey: imageKey)
        DispatchQueue.main.async {
            self.profileImage = nil
        }
        print("🗑️ Profil şəkli silindi")
    }
    
    // MARK: - Helper: Resize Image
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Ən kiçik ratio-nu götür (aspect ratio saxlamaq üçün)
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
}
