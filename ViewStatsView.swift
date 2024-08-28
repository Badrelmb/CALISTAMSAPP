import SwiftUI
import UIKit
import CoreData

struct ViewStatsView: View {
    @State private var selectedProfitPeriod: String = "Total Profit"
    @State private var selectedCategory: String = "All Categories"
    @State private var totalProfit: NSDecimalNumber = 0.0
    @State private var items: [Item] = []

    let profitPeriods = ["Total Profit", "Yearly Profit", "Monthly Profit", "Weekly Profit"]
    let categories = ["All Categories", "Jewelry", "Toys", "Accessories", "Other"]

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Statistics")
                .font(.largeTitle)
                .padding(.top, 20)

            // Profit Period Picker
            Picker("Choose Profit Period:", selection: $selectedProfitPeriod) {
                ForEach(profitPeriods, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Category Picker
            Picker("Choose Category:", selection: $selectedCategory) {
                ForEach(categories, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            // Display Total Profit
            Text("Total Profit: ₩\(Double(truncating: totalProfit), specifier: "%.2f")")
                .font(.title)
                .padding()

            // Horizontal ScrollView
            ScrollView(.horizontal) {
                VStack(alignment: .leading) {
                    // Column Titles
                    HStack {
                        Text("Category")
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)
                        Text("Name/Brand")
                            .font(.headline)
                            .frame(width: 150, alignment: .leading)
                        Text("Photo")
                            .font(.headline)
                            .frame(width: 50, alignment: .center)
                        Text("Date of Sale")
                            .font(.headline)
                            .frame(width: 100, alignment: .leading)
                        Text("Price of Purchase")
                            .font(.headline)
                            .frame(width: 150, alignment: .trailing)
                        Text("Price of Sale")
                            .font(.headline)
                            .frame(width: 150, alignment: .trailing)
                        Text("Profit")
                            .font(.headline)
                            .frame(width: 100, alignment: .trailing)
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
                                    if let image = UIImage(data: item.image ?? Data()) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8)
                                    }
                                    if let dateOfSale = item.dateOfSale {
                                        Text(dateOfSale, style: .date)
                                            .frame(width: 100, alignment: .leading)
                                    } else {
                                        Text("N/A")
                                            .frame(width: 100, alignment: .leading)
                                    }
                                    Text("₩\(Double(truncating: item.priceOfPurchase ?? 0), specifier: "%.2f")")
                                        .frame(width: 150, alignment: .trailing)
                                    Text("₩\(Double(truncating: item.sellingPrice ?? 0), specifier: "%.2f")")
                                        .frame(width: 150, alignment: .trailing)
                                    Text("₩\(Double(truncating: item.profit ?? 0), specifier: "%.2f")")
                                        .frame(width: 100, alignment: .trailing)
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
        .padding()
        .onAppear {
            fetchItems()
        }
        .onChange(of: selectedProfitPeriod) { _, _ in
            calculateTotalProfit()
        }
        .onChange(of: selectedCategory) { _, _ in
            calculateTotalProfit()
        }
    }

    private func fetchItems() {
        self.items = DatabaseManager.shared.fetchItems().filter { $0.isSold }
        calculateTotalProfit()
    }

    private func calculateTotalProfit() {
        let filtered = filteredItems()
        totalProfit = filtered.reduce(NSDecimalNumber.zero) { $0.adding($1.profit ?? NSDecimalNumber.zero) }
    }

    private func filteredItems() -> [Item] {
        return items.filter { item in
            (selectedCategory == "All Categories" || item.category == selectedCategory) &&
            (selectedProfitPeriod == "Total Profit" || isInSelectedPeriod(item: item))
        }
    }

    private func isInSelectedPeriod(item: Item) -> Bool {
        guard let sellingDate = item.dateOfSale else {
            return false
        }
        let calendar = Calendar.current
        let now = Date()

        switch selectedProfitPeriod {
        case "Yearly Profit":
            return calendar.isDate(sellingDate, equalTo: now, toGranularity: .year)
        case "Monthly Profit":
            return calendar.isDate(sellingDate, equalTo: now, toGranularity: .month)
        case "Weekly Profit":
            return calendar.isDate(sellingDate, equalTo: now, toGranularity: .weekOfYear)
        default:
            return true
        }
    }
}

struct ViewStatsView_Previews: PreviewProvider {
    static var previews: some View {
        ViewStatsView()
    }
}
