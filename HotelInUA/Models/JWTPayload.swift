import Foundation

struct SmartKeyPayload: Codable {
    let bookingId: String
    let roomNumber: String
    let exp: TimeInterval
}
