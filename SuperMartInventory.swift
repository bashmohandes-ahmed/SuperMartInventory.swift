import Foundation

// MARK: - Product Model
struct Product: Codable {
    let id: UUID
    var name: String
    var price: Double
    var stock: Int
}

// MARK: - Inventory Manager
class InventoryManager {
    var products: [Product] = []
    private let fileName = "inventory.json"
    
    // File path in Documents directory
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    // Load inventory from JSON file
    func loadInventory() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            products = try decoder.decode([Product].self, from: data)
            print("Loaded \(products.count) products")
        } catch {
            print("No inventory found, starting fresh")
        }
    }
    
    // Save inventory to JSON file
    func saveInventory() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(products)
            try data.write(to: fileURL)
            print("Saved \(products.count) products")
        } catch {
            print("Failed to save inventory: \(error)")
        }
    }
    
    // Add a new product
    func addProduct(name: String, price: Double, stock: Int) {
        let product = Product(id: UUID(), name: name, price: price, stock: stock)
        products.append(product)
        saveInventory()
    }
    
    // Update stock quantity for a product by ID
    func updateStock(productId: UUID, newStock: Int) {
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].stock = newStock
            saveInventory()
        }
    }
    
    // List all products
    func listProducts() {
        for product in products {
            print("Product: \(product.name), Price: $\(product.price), Stock: \(product.stock)")
        }
    }
    
    // List low-stock products (default threshold = 5)
    func lowStockProducts(threshold: Int = 5) {
        let lowStock = products.filter { $0.stock <= threshold }
        if lowStock.isEmpty {
            print("No low-stock products")
        } else {
            for product in lowStock {
                print("LOW STOCK: \(product.name) - \(product.stock) left")
            }
        }
    }
}

// MARK: - Example Usage
let inventory = InventoryManager()

// Load existing inventory
inventory.loadInventory()

// Add new products
inventory.addProduct(name: "Apple", price: 0.99, stock: 20)
inventory.addProduct(name: "Milk", price: 2.49, stock: 3)
inventory.addProduct(name: "Banana", price: 0.59, stock: 10)

// List all products
print("\n--- All Products ---")
inventory.listProducts()

// List low-stock products
print("\n--- Low Stock Products ---")
inventory.lowStockProducts()

// Update stock for Milk
if let milk = inventory.products.first(where: { $0.name == "Milk" }) {
    inventory.updateStock(productId: milk.id, newStock: 15)
}

// List all products after stock update
print("\n--- All Products After Stock Update ---")
inventory.listProducts()

// List low-stock products after stock update
print("\n--- Low Stock Products After Stock Update ---")
inventory.lowStockProducts()
