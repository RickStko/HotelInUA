import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = HotelViewModel()
    
    var body: some View {
        TabView {
            RoomsCatalogView().environmentObject(viewModel)
                .tabItem { Label("Номери", systemImage: "bed.double.fill") }
            
            SmartKeyView().environmentObject(viewModel)
                .tabItem { Label("Ключ", systemImage: "key.fill") }
            
            MyBookingsView().environmentObject(viewModel)
                .tabItem { Label("Бронювання", systemImage: "list.bullet") }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Увага"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("ОК"))
            )
        }
    }
}
#Preview {
    MainTabView()
        .environmentObject(HotelViewModel())
}

