import SwiftUI
import CoreData
import UIKit

struct AddItemView: View {
    @State private var category: String = "Jewelry"
    @State private var name: String = ""
    @State private var dateOfPurchase: Date = Date()
    @State private var priceOfPurchase: String = ""
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @Binding var isPresented: Bool
    @State private var showAlert: Bool = false
    @State private var alertTitle = ""
    @State private var alertMessage: String = ""
    @Environment(\.presentationMode) var presentationMode

    var existingItem: Item?
    var onSave: () -> Void

    // Access to Core Data context
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Category", selection: $category) {
                        Text("Jewelry").tag("Jewelry")
                        Text("Toys").tag("Toys")
                        Text("Accessories").tag("Accessories")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    TextField("Name", text: $name)

                    Button(action: {
                        self.showImagePicker = true
                    }) {
                        Text("Change Photo")
                    }

                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }

                    DatePicker("Date of Purchase", selection: $dateOfPurchase, displayedComponents: .date)

                    TextField("Price of Purchase", text: $priceOfPurchase)
                        .keyboardType(.decimalPad)
                        .padding()
                        .border(Color.gray, width: 1)
                }

                Button(action: {
                    saveItem()
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle(existingItem == nil ? "Add Item" : "Edit Item", displayMode: .inline)
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                // If an existing item is being edited, load its details
                if let existingItem = existingItem {
                    self.category = existingItem.category ?? "Jewelry"
                    self.name = existingItem.name ?? ""
                    self.dateOfPurchase = existingItem.dateOfPurchase ?? Date()
                    if let price = existingItem.priceOfPurchase {
                                self.priceOfPurchase = price.stringValue
                            } else {
                                self.priceOfPurchase = ""
                            }
                    if let imageData = existingItem.image, let uiImage = UIImage(data: imageData) {
                        self.image = Image(uiImage: uiImage)
                        self.inputImage = uiImage
                    }
                }
            }
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }

    func saveItem() {
        // Step 1: Validate required fields
        guard !name.isEmpty else {
            alertTitle = "Error"
            alertMessage = "Name is required."
            showAlert = true
            return
        }

        guard !priceOfPurchase.isEmpty else {
            alertTitle = "Error"
            alertMessage = "A valid Price of Purchase is required."
            showAlert = true
            return
        }

        let priceValue = NSDecimalNumber(string: priceOfPurchase)
        if priceValue == NSDecimalNumber.notANumber {
            alertTitle = "Error"
            alertMessage = "A valid Price of Purchase is required."
            showAlert = true
            return
        }


        // Step 2: Save or Update the Item in Core Data
        if existingItem == nil {
            // Create a new item
            let newItem = Item(context: viewContext)
            newItem.id = UUID()
            newItem.category = category
            newItem.name = name
            newItem.image = inputImage?.jpegData(compressionQuality: 0.8)
            newItem.dateOfPurchase = dateOfPurchase
            newItem.priceOfPurchase = priceValue
            newItem.sellingPrice = nil
            newItem.profit = nil
        } else {
            // Update existing item
            existingItem?.category = category
            existingItem?.name = name
            existingItem?.image = inputImage?.jpegData(compressionQuality: 0.8)
            existingItem?.dateOfPurchase = dateOfPurchase
            existingItem?.priceOfPurchase = priceValue
        }

        do {
            try viewContext.save()
            alertTitle = "Success"
            alertMessage = "Item saved successfully"
            showAlert = true

            // Dismiss the view and return to the main menu after a slight delay to show the alert
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.isPresented = false
            }

            // Call the onSave closure to perform any additional actions
            onSave()

        } catch {
            print("Failed to save item: \(error)")
            alertTitle = "Error"
            alertMessage = "Failed to save item. Please try again."
            showAlert = true
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()
