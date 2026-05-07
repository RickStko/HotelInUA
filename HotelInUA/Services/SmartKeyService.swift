import Foundation
import CryptoKit

class SmartKeyService {
    static let shared = SmartKeyService()
    
    private let secretKeyString = "SuperSecretHotelKey_2026_DoNotShare!"
    
    private init() {}
    
    func generateToken(bookingId: UUID, roomNumber: String, checkOutDate: Date) -> String? {
        let headerJSON = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}".data(using: .utf8)!
        let headerBase64 = headerJSON.base64UrlEncodedString()
        
        let payload = SmartKeyPayload(
            bookingId: bookingId.uuidString,
            roomNumber: roomNumber,
            exp: checkOutDate.timeIntervalSince1970
        )
        
        guard let payloadJSON = try? JSONEncoder().encode(payload) else { return nil }
        let payloadBase64 = payloadJSON.base64UrlEncodedString()
        
        let signatureInput = "\(headerBase64).\(payloadBase64)"
        
        let key = SymmetricKey(data: Data(secretKeyString.utf8))
        let signatureData = Data(signatureInput.utf8)
        let signature = HMAC<SHA256>.authenticationCode(for: signatureData, using: key)
        
        let signatureBase64 = Data(signature).base64UrlEncodedString()
        
        let jwtToken = "\(signatureInput).\(signatureBase64)"
        
        return jwtToken
    }
}

extension SmartKeyService {
    
    enum KeyError: Error {
        case invalidFormat
        case signatureInvalid
        case expired
    }
    
    func validateKey(token: String) throws -> SmartKeyPayload {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { throw KeyError.invalidFormat }
        
        let headerBase64 = parts[0]
        let payloadBase64 = parts[1]
        let signatureBase64 = parts[2]
        
        let signatureInput = "\(headerBase64).\(payloadBase64)"
        let key = SymmetricKey(data: Data(secretKeyString.utf8))
        let expectedSignature = HMAC<SHA256>.authenticationCode(for: Data(signatureInput.utf8), using: key)
        let expectedSignatureBase64 = Data(expectedSignature).base64UrlEncodedString()
        
        if signatureBase64 != expectedSignatureBase64 {
            throw KeyError.signatureInvalid
        }
        
        var base64 = payloadBase64.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        
        guard let payloadData = Data(base64Encoded: base64),
              let payload = try? JSONDecoder().decode(SmartKeyPayload.self, from: payloadData) else {
            throw KeyError.invalidFormat
        }
        
        let currentDate = Date().timeIntervalSince1970
        if currentDate > payload.exp {
            throw KeyError.expired
        }
        
        return payload
    }
}
