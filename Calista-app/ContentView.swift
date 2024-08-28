import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showAddItemView: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo at the top
                Image("Calista_logo2") // Make sure this matches the name of your logo image in Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .padding(20)

                // Welcome text
                Text("Welcome to your product manager app\nGET RICH BABY !")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(20)

                // Buttons stacked vertically
                VStack(spacing: 10) {
                    NavigationLink(destination: ItemListView()) {
                        Text("View items")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showAddItemView = true
                    }) {
                        Text("Add items")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showAddItemView) {
                        AddItemView(isPresented: $showAddItemView, onSave: {
                            // Perform any additional actions after saving
                        })
                    }

                    NavigationLink(destination: ViewStatsView()) {
                        Text("View stats")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                Spacer() // To push content to the top
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
