//
//  StoreManager.swift
//

import Foundation
import StoreKit

/// Handles In-App Purchases.
class StoreManager: NSObject {
    
    /// The singleton instance of the Store.
    static let shared = StoreManager()
    /// An object that can retrieve localized information from the App Store about a specified list of products.
    ///
    /// - Important: Must keep a strong reference.
    var productRequest: SKProductsRequest!
    
    private override init() {}
    
    /// Returns the product identifiers from the `ProductIDs.plist` file. If there is an error, returns nil.
    func getProductIDs() -> [String]? {
        guard SKPaymentQueue.canMakePayments() else {
            print("User is not allowed to make payments.")
            // TODO: Notify user.
            return nil
        }
        guard let path = Bundle.main.path(forResource: "ProductIDs", ofType: "plist") else {
            print("Error: Resource file could not be found.")
            return nil
        }
        guard let productIDs = NSArray(contentsOfFile: path) as? [String] else {
            print("Error: ProductIDs are not Strings.")
            return nil
        }
        return productIDs
    }
    
    /// Request product info from the App Store for the given product `identifiers`.
    ///
    /// The App Store's response is automatically sent to the `SKProductsRequestDelegate` (which in our case is set to `self` in this method).
    func requestProducts(withIdentifiers identifiers: [String]) {
        productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productRequest.delegate = self
        productRequest.start()
    }
    
    /// Requests to purchase the specified product.
    /// - Parameter product: The product to purchase.
    ///
    ///     We can obtain an `SKProduct` to "buy" in our `productsRequest()` delegate method (defined below).
    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    /// Restores all previously purchased items.
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: Product Request Delegate

// Methods that handle response from products request.
extension StoreManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("The fetched products are \(response.products) and the invalid ProductIDs are \(response.invalidProductIdentifiers)")
        // TODO: Handle the SKProducts that we've received (i.e. display them to the user so they can select which one they want to purchase).
    }
    
    // Optional
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error while requesting products: \(error.localizedDescription)")
        // TODO: Alert user.
    }
    
    // Optional
    func requestDidFinish(_ request: SKRequest) {
        print("Products request finished.")
    }
}

// MARK: Payment Queue Delegate

// Methods that handle response from payment transactions (like buying or restoring an IAP).
extension StoreManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased: break // TODO: Handle successful transaction (unlock content).
            case .failed: break // TODO: Handle failed transaction.
            case .restored: break // TODO: Handle restore transaction.
            case .deferred: print("Transaction pending.")
            @unknown default: fatalError("Unknown payment transaction.")
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // Other optional delegate methods available.
}
