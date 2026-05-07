import Foundation

struct Room: Codable, Identifiable{
    let id: UUID
    var number: String
    var type: RoomType
    var price: Double
    var isAvailable: Bool    
}

enum RoomType: String, Codable {
    case standard = "Standart"
    case premium = "Premium"
    case deluxe = "Deluxe"
}
