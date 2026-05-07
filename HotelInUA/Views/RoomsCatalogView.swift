import SwiftUI

struct RoomsCatalogView: View {
    @EnvironmentObject var viewModel: HotelViewModel
    @State private var selectedRoom: Room?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.availableRooms.filter { $0.isAvailable }) { room in
                        RoomCardView(room: room)
                            .onTapGesture {
                                selectedRoom = room
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Каталог номерів")
            .sheet(item: $selectedRoom) { room in
                BookingSheetView(room: room)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct RoomCardView: View {
    let room: Room
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: "bed.double.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.indigo)
                .frame(height: 80)
                .padding()
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(12)
            
            Text("Номер \(room.number)")
                .font(.headline)
            Text(room.type.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(Int(room.price)) ₴ / ніч")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.indigo)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
