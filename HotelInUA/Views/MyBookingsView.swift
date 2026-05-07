import SwiftUI

struct MyBookingsView: View {
    @EnvironmentObject var viewModel: HotelViewModel
    @State private var bookingToEdit: Booking?
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(viewModel.myBookings) { booking in
                        BookingRow(booking: booking)
                            .swipeActions(edge: .leading) {
                                Button {
                                    bookingToEdit = booking
                                } label: {
                                    Label("Змінити", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.cancelBooking(byId: booking.id)
                                } label: {
                                    Label("Скасувати", systemImage: "trash")
                                }
                            }
                    }
                }
                
                if viewModel.myBookings.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("У вас ще немає активних бронювань")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Мої бронювання")
            .sheet(item: $bookingToEdit) { booking in
                if let room = viewModel.availableRooms.first(where: { $0.id == booking.roomId }) {
                    BookingSheetView(room: room, editingBooking: booking)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}
struct BookingRow: View {
    let booking: Booking
    @EnvironmentObject var viewModel: HotelViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let roomNumber = viewModel.availableRooms.first(where: { $0.id == booking.roomId })?.number ?? "Невідомо"
            
            Text("Кімната: \(roomNumber)")
                .font(.headline)
            
            Text("Гість: \(booking.guestName)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar.badge.clock")
                Text("\(booking.checkIn.formatted(date: .abbreviated, time: .omitted)) - \(booking.checkOut.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
            }
            
            Text("Статус: \(booking.status.rawValue)")
                .font(.caption)
                .foregroundColor(.green)
                .padding(4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}
