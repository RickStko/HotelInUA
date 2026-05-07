import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    public var connection: Connection?
    
    let roomsTable = Table("rooms")
    let bookingsTable = Table("bookings")
    
    let roomId = Expression<String>("id")
    let roomNumber = Expression<String>("number")
    let roomType = Expression<String>("type")
    let price = Expression<Double>("price")
    let isAvailable = Expression<Bool>("is_available")
    
    let bookingId = Expression<String>("id")
    let bRoomId = Expression<String>("room_id")
    let guestName = Expression<String>("guest_name")
    let checkIn = Expression<Date>("check_in")
    let checkOut = Expression<Date>("check_out")
    let bStatus = Expression<String>("status")
    
    private init() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("hotel_database").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.connection = database
            
            try? createTables()
            
        } catch {
            print("Помилка підключення до бази даних SQLite: \(error)")
        }
    }
}

extension DatabaseManager {
    func createTables() throws {
        guard let db = connection else { return }
        
        try db.run(roomsTable.create(ifNotExists: true) { t in
            t.column(roomId, primaryKey: true)
            t.column(roomNumber, unique: true)
            t.column(roomType)
            t.column(price)
            t.column(isAvailable, defaultValue: true)
        })
        
        try db.run(bookingsTable.create(ifNotExists: true) { t in
            t.column(bookingId, primaryKey: true)
            t.column(bRoomId)
            t.column(guestName)
            t.column(checkIn)
            t.column(checkOut)
            t.column(bStatus)
            t.foreignKey(bRoomId, references: roomsTable, roomId, update: .cascade, delete: .cascade)
        })
    }
}
extension DatabaseManager {
    func createBooking(booking: Booking) throws {
        guard let db = connection else { return }
        
        let insert = bookingsTable.insert(
            bookingId <- booking.id.uuidString,
            bRoomId <- booking.roomId.uuidString,
            guestName <- booking.guestName,
            checkIn <- booking.checkIn,
            checkOut <- booking.checkOut,
            bStatus <- booking.status.rawValue
        )
        
        try db.run(insert)
    }
}
extension DatabaseManager {
    func updateRoomStatus(roomIdToUpdate: UUID, isAvailableStatus: Bool) throws {
        guard let db = connection else { return }
        
        let roomToUpdate = roomsTable.filter(roomId == roomIdToUpdate.uuidString)
        try db.run(roomToUpdate.update(isAvailable <- isAvailableStatus))
    }
}
extension DatabaseManager {
    func updateBooking(booking: Booking) throws {
        guard let db = connection else { return }
        let item = bookingsTable.filter(bookingId == booking.id.uuidString)
        
        try db.run(item.update(
            guestName <- booking.guestName,
            checkIn <- booking.checkIn,
            checkOut <- booking.checkOut,
            bStatus <- booking.status.rawValue
        ))
    }
}
extension DatabaseManager {
    func fetchAvailableRooms() throws -> [Room] {
        guard let db = connection else { return [] }
        var resultRooms: [Room] = []
        
        let query = roomsTable.filter(isAvailable == true)
        
        for row in try db.prepare(query) {
            let room = Room(
                id: UUID(uuidString: row[roomId]) ?? UUID(),
                number: row[roomNumber],
                type: RoomType(rawValue: row[roomType]) ?? .standard,
                price: row[price],
                isAvailable: row[isAvailable]
            )
            resultRooms.append(room)
        }
        return resultRooms
    }
}
extension DatabaseManager {
    func cancelBooking(bookingIdToCancel: UUID, roomIdToFree: UUID) throws {
        guard let db = connection else { return }
        
        try db.transaction {
            let bookingToCancel = bookingsTable.filter(bookingId == bookingIdToCancel.uuidString)
            try db.run(bookingToCancel.update(bStatus <- BookingStatus.cancelled.rawValue))
            
            let roomToFree = roomsTable.filter(roomId == roomIdToFree.uuidString)
            try db.run(roomToFree.update(isAvailable <- true))
        }
    }
}
