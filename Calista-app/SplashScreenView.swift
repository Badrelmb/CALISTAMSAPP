import SwiftUI
import UIKit

struct SplashScreenView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color(red: 252/255, green: 186/255, blue: 211/255) // Set the background color to match the pink background of your logo
                .edgesIgnoringSafeArea(.all)

            if isActive {
                ContentView() // The main page of your app
            } else {
                Image("CalistaSplashScreen") // Ensure this matches the name of your logo image in Assets.xcassets
                    .resizable()
                    .aspectRatio(contentMode: .fit) // Maintain aspect ratio without distortion
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the screen
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
