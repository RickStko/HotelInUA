import Foundation

struct Booking: Codable, Identifiable{
    let id: UUID
    let roomId: UUID
    var guestName: String
    var checkIn: Date
    var checkOut: Date
    var status: BookingStatus
}

enum BookingStatus: String, Codable {
    case active = "Active"
    case cancelled = "Cancelled"
    case completed = "Completed"
}
