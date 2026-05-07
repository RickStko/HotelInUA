import SwiftUI

struct BookingSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: HotelViewModel
    
    let room: Room
    var editingBooking: Booking?
    
    @State private var guestName: String = ""
    @State private var checkInDate = Date()
    @State private var checkOutDate = Date().addingTimeInterval(86400)
    
    var isEditMode: Bool { editingBooking != nil }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Дані гостя")) {
                    TextField("Прізвище та ім'я", text: $guestName)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Період проживання")) {
                    DatePicker("Заїзд", selection: $checkInDate, in: Date()..., displayedComponents: .date)
                        .onChange(of: checkInDate) { oldValue, newValue in
                            if checkOutDate <= newValue {
                                checkOutDate = newValue.addingTimeInterval(86400)
                            }
                        }
                    
                    DatePicker("Виїзд", selection: $checkOutDate, in: checkInDate.addingTimeInterval(86400)..., displayedComponents: .date)
                }
                
                Section {
                    Button(action: saveAction) {
                        Text(isEditMode ? "Зберегти зміни" : "Підтвердити бронювання")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                    .disabled(guestName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .listRowBackground(guestName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray.opacity(0.2) : Color.indigo)
                    .foregroundColor(.white)
                }
            }
            .navigationTitle(isEditMode ? "Редагування" : "Бронювання")
            .onAppear {
                setupInitialData()
            }
        }
    }
    
    private func setupInitialData() {
        if let booking = editingBooking {
            guestName = booking.guestName
            checkInDate = booking.checkIn
            checkOutDate = booking.checkOut
        }
    }
    
    private func saveAction() {
        if isEditMode, let original = editingBooking {
            let updated = Booking(
                id: original.id,
                roomId: original.roomId,
                guestName: guestName,
                checkIn: checkInDate,
                checkOut: checkOutDate,
                status: original.status
            )
            viewModel.updateBooking(updated)
        } else {
            viewModel.bookRoom(room, guestName: guestName, checkIn: checkInDate, checkOut: checkOutDate)
        }
        presentationMode.wrappedValue.dismiss()
    }
}
