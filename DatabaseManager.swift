import Foundation
import CoreData
import SwiftUI

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Add Item
    
    func addItem(category: String, name: String, photos: Data, dateOfPurchase: Date, priceOfPurchase: NSDecimalNumber) {
        let newItem = Item(context: context)
        newItem.id = UUID() // Use UUID for id
        newItem.category = category
        newItem.name = name
        newItem.image = photos
        newItem.dateOfPurchase = dateOfPurchase
        newItem.priceOfPurchase = priceOfPurchase
        newItem.sellingPrice = nil
        newItem.profit = nil
        
        saveContext()
    }
    
    // MARK: - Fetch Items
    
    func fetchItems() -> [Item] {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching items: \(error)")
            return []
        }
    }
    
    // MARK: - Update Item
    
    func updateItem(_ item: Item) {
        saveContext()
    }
    
    // MARK: - Delete Item
    
    func deleteItem(_ item: Item) {
        context.delete(item)
        saveContext()
    }
    
    // MARK: - Save Context
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
