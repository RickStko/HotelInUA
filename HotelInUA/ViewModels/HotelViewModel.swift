import SwiftUI
import Combine

class HotelViewModel: ObservableObject {
    @Published var availableRooms: [Room] = []
    @Published var myBookings: [Booking] = []
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var activeJWT: String? = UserDefaults.standard.string(forKey: "active_smart_key")
    func triggerError(_ message: String = "Помилка в опрацюванні запиту") {
        self.errorMessage = message
        self.showError = true
    }
    init() {
        loadMockData()
        
        if myBookings.isEmpty {
            activeJWT = nil
            UserDefaults.standard.removeObject(forKey: "active_smart_key")
        }
    }
    
    func bookRoom(_ room: Room, guestName: String, checkIn: Date, checkOut: Date) {
        let newBooking = Booking(
            id: UUID(),
            roomId: room.id,
            guestName: guestName,
            checkIn: checkIn,
            checkOut: checkOut,
            status: .active
        )
        
        do {
            // Для Симулятора
            try DatabaseManager.shared.createBooking(booking: newBooking)
            try DatabaseManager.shared.updateRoomStatus(roomIdToUpdate: room.id, isAvailableStatus: false)
            
            myBookings.append(newBooking)
            
            if let index = availableRooms.firstIndex(where: { $0.id == room.id }) {
                availableRooms[index].isAvailable = false
            }
            
            let mockJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.payload.signature"
            activeJWT = mockJWT
            UserDefaults.standard.set(mockJWT, forKey: "active_smart_key")
            
        } catch {
            triggerError("Не вдалося створити бронювання")
        }
    }
    func updateBooking(_ booking: Booking) {
        do {
            try DatabaseManager.shared.updateBooking(booking: booking)
            
            if let index = myBookings.firstIndex(where: { $0.id == booking.id }) {
                myBookings[index] = booking
            }
        } catch {
            triggerError("Не вдалося оновити дані бронювання")
        }
    }
    func cancelBooking(byId id: UUID) {
        guard let index = myBookings.firstIndex(where: { $0.id == id }) else { return }
        let booking = myBookings[index]
        
        do {
            //Для Симулятора
            try DatabaseManager.shared.cancelBooking(bookingIdToCancel: booking.id, roomIdToFree: booking.roomId)
            
            if let roomIndex = availableRooms.firstIndex(where: { $0.id == booking.roomId }) {
                availableRooms[roomIndex].isAvailable = true
            }
            
            myBookings.remove(at: index)
            
            if myBookings.isEmpty {
                activeJWT = nil
                UserDefaults.standard.removeObject(forKey: "active_smart_key")
            }
        } catch {
            triggerError("Не вдалося скасувати бронювання")
        }
    }
    
    private func loadMockData() {
        availableRooms = [
            Room(id: UUID(), number: "101", type: .standard, price: 1200, isAvailable: true),
            Room(id: UUID(), number: "102", type: .standard, price: 1200, isAvailable: true),
            Room(id: UUID(), number: "103", type: .standard, price: 1200, isAvailable: true),
            Room(id: UUID(), number: "201", type: .premium, price: 2500, isAvailable: true),
            Room(id: UUID(), number: "202", type: .premium, price: 2500, isAvailable: true),
            Room(id: UUID(), number: "301", type: .deluxe, price: 4000, isAvailable: true),
            Room(id: UUID(), number: "302", type: .deluxe, price: 4500, isAvailable: true)
        ]
    }
}
