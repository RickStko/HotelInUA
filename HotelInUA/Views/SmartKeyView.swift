import SwiftUI

struct SmartKeyView: View {
    @EnvironmentObject var viewModel: HotelViewModel
    @State private var isPulsating = false
    @State private var accessMessage = "Натисніть для відкриття дверей"
    @State private var unlockColor: Color = .indigo
    
    let qrGenerator = QRCodeGenerator()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                if let token = viewModel.activeJWT {
                    Text("Піднесіть код до сканера")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(uiImage: qrGenerator.generateQRCode(from: token))
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    
                    Button(action: {
                        openDoor()
                    }) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 100)
                            .background(Circle().fill(unlockColor))
                            .scaleEffect(isPulsating ? 1.15 : 1.0)
                            .shadow(color: unlockColor.opacity(0.5), radius: isPulsating ? 20 : 5)
                            .animation(
                                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                                value: isPulsating
                            )
                    }
                    .onAppear { isPulsating = true }
                    
                    Text(accessMessage)
                        .font(.headline)
                        .foregroundColor(unlockColor)
                    
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "key.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("У вас немає активного ключа.\nЗабронюйте номер, щоб отримати доступ.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Мій Ключ")
        }
    }
    
    func openDoor() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        withAnimation {
            unlockColor = .green
            accessMessage = "Двері відчинено! Ласкаво просимо."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                unlockColor = .indigo
                accessMessage = "Натисніть для відкриття дверей"
            }
        }
    }
}
