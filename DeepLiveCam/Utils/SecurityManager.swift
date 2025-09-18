import Foundation
import Security
import CryptoKit

class SecurityManager {
    static let shared = SecurityManager()
    
    private init() {}
    
    // MARK: - Data Encryption
    
    func encryptData(_ data: Data, with key: String) -> Data? {
        guard let keyData = key.data(using: .utf8) else { return nil }
        
        let symmetricKey = SymmetricKey(data: keyData)
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            return sealedBox.combined
        } catch {
            Logger.shared.error("Encryption failed: \(error)")
            return nil
        }
    }
    
    func decryptData(_ encryptedData: Data, with key: String) -> Data? {
        guard let keyData = key.data(using: .utf8) else { return nil }
        
        let symmetricKey = SymmetricKey(data: keyData)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            return try AES.GCM.open(sealedBox, using: symmetricKey)
        } catch {
            Logger.shared.error("Decryption failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Key Generation
    
    func generateSecureKey() -> String {
        let keyData = SymmetricKey(size: .bits256)
        return keyData.withUnsafeBytes { bytes in
            Data(bytes).base64EncodedString()
        }
    }
    
    func generateRandomString(length: Int) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    // MARK: - Secure Storage
    
    func storeSecurely(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieveSecurely(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            Logger.shared.warning("Failed to retrieve secure data: \(status)")
            return nil
        }
        
        return result as? Data
    }
    
    func deleteSecurely(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
    
    // MARK: - Data Validation
    
    func validateImageData(_ data: Data) -> Bool {
        // Check file signature
        guard data.count > 8 else { return false }
        
        let header = data.prefix(8)
        
        // Check for common image formats
        if header.starts(with: [0xFF, 0xD8, 0xFF]) { // JPEG
            return true
        } else if header.starts(with: [0x89, 0x50, 0x4E, 0x47]) { // PNG
            return true
        } else if header.starts(with: [0x47, 0x49, 0x46]) { // GIF
            return true
        } else if header.starts(with: [0x52, 0x49, 0x46, 0x46]) { // WebP
            return true
        }
        
        return false
    }
    
    func validateVideoData(_ data: Data) -> Bool {
        // Check file signature
        guard data.count > 12 else { return false }
        
        let header = data.prefix(12)
        
        // Check for common video formats
        if header.starts(with: [0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70]) { // MP4
            return true
        } else if header.starts(with: [0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70]) { // MOV
            return true
        } else if header.starts(with: [0x1A, 0x45, 0xDF, 0xA3]) { // WebM
            return true
        }
        
        return false
    }
    
    // MARK: - Privacy Protection
    
    func sanitizeImageData(_ data: Data) -> Data? {
        // Remove EXIF data and other metadata
        guard let image = UIImage(data: data) else { return nil }
        
        // Create new image without metadata
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let sanitizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return sanitizedImage?.jpegData(compressionQuality: 0.8)
    }
    
    func removeMetadata(from image: UIImage) -> UIImage? {
        // Create new image without metadata
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let cleanImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cleanImage
    }
    
    // MARK: - Access Control
    
    func checkBiometricAvailability() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = "Authenticate to access secure features"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - Secure Communication
    
    func createSecureURL(_ urlString: String) -> URL? {
        guard let url = URL(string: urlString) else { return nil }
        
        // Ensure HTTPS
        guard url.scheme == "https" else {
            Logger.shared.warning("Insecure URL detected: \(urlString)")
            return nil
        }
        
        return url
    }
    
    func validateCertificate(for url: URL) -> Bool {
        // In a real app, you would implement proper certificate validation
        // This is a simplified version
        return url.scheme == "https"
    }
}

// MARK: - Security Extensions

extension Data {
    func sha256() -> String {
        let hash = SHA256.hash(data: self)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func base64Encoded() -> String {
        return self.base64EncodedString()
    }
}

extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        return data.sha256()
    }
}

// MARK: - Security Constants

struct SecurityConstants {
    static let encryptionKey = "DeepLiveCamEncryptionKey"
    static let maxFileSize = 100 * 1024 * 1024 // 100MB
    static let allowedImageFormats = ["jpg", "jpeg", "png", "heic", "webp"]
    static let allowedVideoFormats = ["mp4", "mov", "m4v", "webm"]
    static let minPasswordLength = 8
    static let maxPasswordLength = 128
}

// MARK: - Security Manager Delegate

protocol SecurityManagerDelegate: AnyObject {
    func securityManagerDidDetectThreat(_ manager: SecurityManager, threat: SecurityThreat)
    func securityManagerDidAuthenticate(_ manager: SecurityManager, success: Bool)
}

// MARK: - Security Threat

enum SecurityThreat {
    case suspiciousFile
    case invalidCertificate
    case unauthorizedAccess
    case dataTampering
    case networkInterception
}

// MARK: - Security Manager Extension

extension SecurityManager {
    func detectThreats(in data: Data) -> [SecurityThreat] {
        var threats: [SecurityThreat] = []
        
        // Check file size
        if data.count > SecurityConstants.maxFileSize {
            threats.append(.suspiciousFile)
        }
        
        // Check for suspicious patterns
        if data.contains("eval(") || data.contains("exec(") {
            threats.append(.suspiciousFile)
        }
        
        return threats
    }
    
    func logSecurityEvent(_ event: String, level: SecurityLevel) {
        Logger.shared.info("Security Event [\(level.rawValue)]: \(event)")
    }
}

enum SecurityLevel: String {
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
}
