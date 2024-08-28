import SwiftUI
import UIKit
import CoreData

struct ItemListView: View {
    @State private var selectedCategory: String = "All categories"
    @State private var searchText: String = ""
    
    @State private var showEditView: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var itemToEdit: Item? = nil
    @State private var itemToDelete: Item? = nil
    @State private var showSellConfirmation: Bool = false
    @State private var itemToSell: Item? = nil

    let categories = ["All categories", "Jewelry", "Toys", "Accessories", "Other"]

    // Core Data fetch request
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.dateOfPurchase, ascending: true)]
    ) var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            VStack {
                Text("Item List")
                    .font(.largeTitle)
                    .padding()

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                HStack {
                    TextField("Search by Name", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: searchItems) {
                        Text("Search")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                // Horizontal ScrollView
                ScrollView(.horizontal) {
                    VStack(alignment: .leading) {
                        // Column Titles
                        HStack {
                            Text("Category")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            Text("Name")
                                .font(.headline)
                                .frame(width: 150, alignment: .leading)
                            Text("Image")
                                .font(.headline)
                                .frame(width: 50, alignment: .center)
                            Text("Date of Purchase")
                                .font(.headline)
                                .frame(width: 100, alignment: .leading)
                            Text("Price of Purchase")
                                .font(.headline)
                                .frame(width: 100, alignment: .trailing)
                            Text("Selling Price")
                                .font(.headline)
                                .frame(width: 150, alignment: .trailing)
                            Text("Profit")
                                .font(.headline)
                                .frame(width: 100, alignment: .trailing)
                            Spacer()
                            Text("Actions")
                                .font(.headline)
                                .frame(alignment: .trailing)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        
                        // Vertical ScrollView for list of items
                        ScrollView(.vertical) {
                            LazyVStack {
                                ForEach(filteredItems(), id: \.id) { item in
                                    HStack {
                                        Text(item.category ?? "")
                                            .frame(width: 100, alignment: .leading)
                                        Text(item.name ?? "")
                                            .frame(width: 150, alignment: .leading)
                                        if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        if let dateOfPurchase = item.dateOfPurchase {
                                            Text(dateOfPurchase, style: .date)
                                                .frame(width: 100, alignment: .leading)
                                        } else {
                                            Text("N/A")
                                                .frame(width: 100, alignment: .leading)
                                        }
                                        Text("₩\(Double(truncating: item.priceOfPurchase ?? 0), specifier: "%.2f")")
                                            .frame(width: 100, alignment: .trailing)
                                        
                                        // Selling price input or static text
                                        if item.isSold {
                                            Text("₩\(Double(truncating: item.sellingPrice ?? 0), specifier: "%.2f")")
                                                .frame(width: 150, alignment: .trailing)
                                        } else {
                                            TextField("Enter Selling Price", text: Binding(
                                                get: {
                                                    item.sellingPrice?.stringValue ?? ""
                                                },
                                                set: { newValue in
                                                    let value = NSDecimalNumber(string: newValue)
                                                    if value != NSDecimalNumber.notANumber {
                                                        item.sellingPrice = value
                                                        saveContext()
                                                    }
                                                }
                                            ))
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.decimalPad)
                                            .frame(width: 150, alignment: .trailing)
                                        }
                                        
                                        // Profit calculation
                                        Text("₩\(Double(truncating: item.profit ?? 0), specifier: "%.2f")")
                                            .frame(width: 100, alignment: .trailing)

                                        Spacer()

                                        // Actions
                                        HStack {
                                            NavigationLink(destination: AddItemView(isPresented: $showEditView, existingItem: item, onSave: {
                                                // Handle any post-save actions here if necessary
                                            })) {
                                                Text("Edit")
                                                    .padding(5)
                                                    .background(Color.orange)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(5)
                                            }

                                            if !item.isSold {
                                                Button(action: {
                                                    print("Sell button pressed for item: \(item.name ?? "Unknown")")
                                                    itemToSell = item
                                                    showSellConfirmation = true
                                                }) {
                                                    Text("Sell")
                                                        .padding(5)
                                                        .background(Color.green)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(5)
                                                }
                                            }

                                            Button(action: { confirmDelete(item) }) {
                                                Text("Delete")
                                                    .padding(5)
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(5)
                                            }
                                        }
                                    }
                                    .padding(.vertical, 5)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal) // Padding for the outer ScrollView
            }
            .alert(isPresented: .constant(showSellConfirmation || showAlert)) {
                if showSellConfirmation {
                    return Alert(
                        title: Text("Confirm Sale"),
                        message: Text("Please confirm the price of sale at ₩\(Double(truncating: itemToSell?.sellingPrice ?? 0), specifier: "%.2f")"),
                        primaryButton: .destructive(Text("Confirm")) {
                            print("Sale confirmed for item: \(itemToSell?.name ?? "Unknown")")
                            completeSale(for: itemToSell)
                        },
                        secondaryButton: .cancel {
                            print("Sale cancelled")
                            showSellConfirmation = false
                        }
                    )
                } else {
                    return Alert(
                        title: Text(alertTitle),
                        message: Text(alertMessage),
                        primaryButton: .destructive(Text("Confirm")) {
                            if let item = itemToDelete {
                                deleteItem(item)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }

    // Filter items based on selected category and search text
    func filteredItems() -> [Item] {
        items.filter { item in
            (selectedCategory == "All categories" || item.category == selectedCategory) &&
            (searchText.isEmpty || (item.name?.lowercased().contains(searchText.lowercased()) ?? false))
        }
    }

    // Search button action
    func searchItems() {
        // Core Data fetch request is automatically refreshed, so no need to manually load items
    }

    // Edit item action
    func editItem(_ item: Item) {
        itemToEdit = item
        showEditView = true
    }

    // Complete sale action
    func completeSale(for item: Item?) {
        guard let item = item else {
            print("No item to sell")
            return
        }
        print("Completing sale for item: \(item.name ?? "Unknown")")
        item.isSold = true
        item.dateOfSale = Date()  // Set the current date as the date of sale
        if let sellingPrice = item.sellingPrice {
            item.profit = sellingPrice.subtracting(item.priceOfPurchase ?? 0)
            print("Selling Price: \(sellingPrice), Profit: \(item.profit ?? 0)")
        } else {
            print("No selling price provided")
        }
        // Verify that category and name are set
            print("Category: \(item.category ?? "Unknown"), Name: \(item.name ?? "Unknown")")
        saveContext()
        showSellConfirmation = false
        print("Sale completed and context saved")
    }

    // Confirm delete action
    func confirmDelete(_ item: Item) {
        itemToDelete = item
        alertTitle = "Delete Item"
        alertMessage = "Are you sure you want to delete this item?"
        showAlert = true
    }

    // Delete item from database
    func deleteItem(_ item: Item) {
        guard let context = item.managedObjectContext else { return }
        context.delete(item)
        saveContext()
    }

    // Save context to persist changes
    func saveContext() {
        do {
            try items.first?.managedObjectContext?.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
