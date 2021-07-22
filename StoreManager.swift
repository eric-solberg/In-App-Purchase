//
//  StoreManager.swift
//

import Foundation
import StoreKit

class StoreManager: NSObject {
    
    /// The singleton instance of the Store.
    static let shared = StoreManager()
    /// An object that can retrieve localized information from the App Store about a specified list of products.
    ///
    /// - Important: Must keep a strong reference.
    var productRequest: SKProductsRequest!
    
    private override init() {}
    
    /// Request product info from the App Store on the given product `identifiers`.
    ///
    /// The App Store's response is automatically sent to the `SKProductsRequestDelegate` (which in our case is the Store's singleton instance).
    func requestProducts(withIdentifiers identifiers: [String]) {
        productRequest = SKProductsRequest(productIdentifiers: Set(identifiers))
        productRequest.delegate = self
        productRequest.start()
    }
    
    /// Requests to purchase the specified product.
    /// - Parameter product: The product to purchase.
    ///
    ///     SKProduct objects are returned as part of an SKProductsResponse object.
    func buy(_ product: SKProduct) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    /// Restores all previously purchased items.
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// Methods that handle response from products request.
extension StoreManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("The fetched products are \(response.products) and the invalid ProductIDs are \(response.invalidProductIdentifiers)")
    }
    
    // Optional
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error while requesting products: \(error.localizedDescription)")
    }
    
    // Optional
    func requestDidFinish(_ request: SKRequest) {
        print("Products request finished.")
    }
}

// Methods that handle response from payment transactions (like buying or restoring an IAP).
extension StoreManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: break
            case .purchased: break // Handle successful transaction (unlock content here).
            case .failed: break // Handle failed transaction.
            case .restored: break // Handle restore transaction.
            case .deferred: print("Transaction pending.")
            @unknown default: fatalError("Unknown payment transaction.")
            }
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    // Other optional delegate methods available.
}
