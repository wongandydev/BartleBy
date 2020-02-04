//
//  StoreViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/16/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

import UIKit
import StoreKit

class StoreViewController: UIViewController {
    // MARK: IAP Variables
    private let productIdentifiers: Set<String> = [Constants.noAdIdentifier]
    
    // A set of productsId that is purchased.
    private var purchasedProductsId = Set<String>()
    // Instance of a SkProductsRequest used to request product in this class.
    private var productsRequest = SKProductsRequest()
        // All the products grabbed from SKProductsRequest call
    private var iapProducts = [SKProduct]()
    // All the price of the products grabbed from SKProductsRequest call
    private var iapProductPrice = [String]() {
        didSet {
            if iapProductPrice.count == iapProducts.count {
                DispatchQueue.main.async {
                    if let productPrice = self.iapProductPrice.first {
                        self.purchaseButton.setTitle("Remove ads for \(productPrice)", for: .normal)
                        self.showPurchaseButton()
                    }
                }
            }
        }
    }
    
    // MARK:Views
    private let purchaseButton = UIButton()
    private let purchaseDateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        
        if UserDefaults.standard.bool(forKey: Constants.noAdIdentifier) == true { // 'noAds' purchased
            purchaseButton.isHidden = true
            getUserPurchaseDates(for: Constants.noAdIdentifier)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if iapProducts.isEmpty && UserDefaults.standard.bool(forKey: Constants.noAdIdentifier) == false {
            fetchAllAvailableProducts()
        }
    }
    
    private func layoutSubviews() {
        self.view.backgroundColor = .backgroundColor
        
        purchaseButton.backgroundColor = .backgroundColorReversed
        purchaseButton.setTitleColor(.backgroundColor, for: .normal)
        purchaseButton.setTitleColor(UIColor.backgroundColor.withAlphaComponent(0.4), for: .selected)
        purchaseButton.addTarget(self, action: #selector(purchaseNoAds), for: .touchUpInside)
        purchaseButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        purchaseButton.isHidden = true

        
        self.view.addSubview(purchaseButton)
        purchaseButton.snp.makeConstraints({ make in
            make.center.equalToSuperview()
        })
        
        purchaseDateLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        purchaseDateLabel.numberOfLines = 0
        purchaseDateLabel.textAlignment = .center
        
        self.view.addSubview(purchaseDateLabel)
        purchaseDateLabel.snp.makeConstraints({ make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
        })
        
    }
    
    private func showPurchaseButton() {
        purchaseButton.isHidden = false
    }
    
    //Check if user can make purchases
    private func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private func getUserPurchaseDates(for productIdentifier: String) {
        FirebaseNetworkingService.getUserPurchaseDate(forProductIdentifier: productIdentifier, { isCompleted, timestamp in
            if isCompleted {
                
                self.purchaseDateLabel.text = "Remove Ads was purchased on \(Helper.dbDateToDisplayString(date: Helper.dbStringToDate(timestamp: timestamp)))"
            }
        })
    }
    
    private func clearQueue() {
        for transaction in SKPaymentQueue.default().transactions {
            if (transaction.transactionState == SKPaymentTransactionState.failed) || transaction.transactionState == SKPaymentTransactionState.purchased || transaction.transactionState == SKPaymentTransactionState.restored{
               SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    private func dismissVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func purchaseNoAds() {
        if canMakePurchases() {
            if let product = iapProducts.first {
                let payment = SKPayment(product: product)

                if !SKPaymentQueue.default().transactions.isEmpty { //Unfinished transactions -- poor network + transanction canceled when app closed
                    clearQueue()
                }

                //sets VC as a payment transaction observer
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(payment)
                
                Spinner.start(view: self.view)
                
                print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            }
        } else {
            print("Purchases are disabled")
            alertMessage(title: "Purchases Disabled", message: "Seems like purchasing has been disabled for you.")
        }
    }
    
    //Grabs all the available products based on the product Identifiers that are given.
    private func fetchAllAvailableProducts() {
        productsRequest.cancel()
        Spinner.start(view: self.view)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension StoreViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            iapProducts = response.products
            for product in iapProducts{
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                
                let price1Str = numberFormatter.string(from: product.price)
                iapProductPrice.append("\(price1Str ?? "Price Not Found")")
            }
        }
        
        DispatchQueue.main.async {
            Spinner.stop()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Error at restoring completed transations: \(error.localizedDescription)")
        DispatchQueue.main.async {
            Spinner.stop()
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            DispatchQueue.main.async {
                Spinner.stop()
                self.dismissAfterOKActionAlert(title: "Restore Failed", message: "Nothing to restore")
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                //Don't need to do anything since this app is 17+ there won't be any kids that need to ask parents for permission to purchase item.
                break
            case .purchasing:
                break
            }
        }
    }
    
    //Handle Completed Transaction
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        setProductPurchased(identifier: transaction.payment.productIdentifier, transaction: transaction)
        
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async {
            Spinner.stop()
            self.dismissVC()
        }
    }
    
    //Handle Restore Transaction
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        
        setProductPurchased(identifier: productIdentifier, transaction: transaction)
        
        SKPaymentQueue.default().finishTransaction(transaction)
        DispatchQueue.main.async {
            Spinner.stop()
            self.dismissAfterOKActionAlert(title: "You're all set.", message: "Your past purchase has been restored.")
        }

    }
    
    //Handle Failed Transaction
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
        
        DispatchQueue.main.async {
            Spinner.stop()
        }
    }
    
    //A Glorified function that basically sets user defaults to know whether a product is purchased and send the user an alert that the product is purchased.
    private func setProductPurchased(identifier: String?, transaction: SKPaymentTransaction) {
        guard let identifier = identifier else { return }
        
        //Grab current Transaction's Product ID
        let transactionProductIdentifier = transaction.payment.productIdentifier

        //The product identifier restored is one of the products that is available in this app version
        if let currentTransactionTimeInterval = transaction.transactionDate?.timeIntervalSince1970,
            //Get product's display title from the fetched products at ViewDidLoad
            let productTitle = iapProducts.filter({ $0.productIdentifier == identifier}).first?.localizedTitle,
            //Get the currencyCode from StoreKit aka User's iTunes Currency
            let userCurrencyCode = iapProducts.filter({ $0.productIdentifier == transactionProductIdentifier}).first?.priceLocale.currencyCode,
            //Get transaction price
            let transactionPrice = iapProducts.filter({ $0.productIdentifier == transactionProductIdentifier}).first?.price {
            
            //from 149.99 to 14999
            let transactionPriceNoDecimal = transactionPrice.multiplying(byPowerOf10: 2)
            
            //Checks to see if this is the original transaction
            if transaction.original?.transactionDate?.timeIntervalSince1970 == nil {
               //First transactin aka user is purchasing
                FirebaseNetworkingService.storePurchaseData(productId: transactionProductIdentifier,
                                                            currencyCode: userCurrencyCode,
                                                            price: Int(transactionPrice),
                                                            timestamp: Int(currentTransactionTimeInterval), { isCompleted in
                    print("saved purchase data")
                })
                
                UserDefaults.standard.set(true, forKey: identifier) //Will use this at Program to unlock timeline
            } else {
                //User is restoring this product.
                //Get user's original transaction purchase timeintercal
                if let originalTransactionTimeInterval = transaction.original?.transactionDate?.timeIntervalSince1970 {
                    FirebaseNetworkingService.storePurchaseData(productId: transactionProductIdentifier,
                                                                currencyCode: userCurrencyCode,
                                                                price: Int(transactionPrice),
                                                                timestamp: Int(currentTransactionTimeInterval), { isCompleted in
                        print("saved purchase data")
                    })
                    
                    UserDefaults.standard.set(true, forKey: identifier) //Will use this at Program to unlock timeline]
                }
            }
        }
    }
}

