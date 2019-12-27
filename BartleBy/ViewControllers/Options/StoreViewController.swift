//
//  StoreViewController.swift
//  BartleBy
//
//  Created by Andy Wong on 12/16/19.
//  Copyright © 2019 Andy Wong. All rights reserved.
//

//import UIKit
//import StoreKit
//
//class StoreViewController: UIViewController {
//    fileprivate var iapProducts = [SKProduct]()
//    
//}
//
//extension StoreViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        if response.products.count > 0 {
//            iapProducts = response.products
//            for product in iapProducts{
//                let numberFormatter = NumberFormatter()
//                numberFormatter.formatterBehavior = .behavior10_4
//                numberFormatter.numberStyle = .currency
//                numberFormatter.locale = product.priceLocale
//                var productionSubscriptionPeriod = ""
//                if #available(iOS 11.2, *) {
//                    switch product.subscriptionPeriod?.unit.rawValue{
//                    case 0:
//                        if product.subscriptionPeriod?.numberOfUnits == 7 {
//                            productionSubscriptionPeriod = "/week"
//                            subscriptionUnit = "week"
//                        } else {
//                            productionSubscriptionPeriod = "/day"
//                            subscriptionUnit = "day"
//                        }
//                    case 1:
//                        productionSubscriptionPeriod = "/week"
//                        subscriptionUnit = "week"
//                    case 2:
//                        productionSubscriptionPeriod = "/month"
//                        subscriptionUnit = "month"
//                    case 3:
//                        productionSubscriptionPeriod = "/year"
//                        subscriptionUnit = "year"
//                    case .none:
//                        break
//                    case .some(_):
//                        break
//                    }
//                } else {
//                    // Fallback on earlier versions
//                }
//                
//                let price1Str = numberFormatter.string(from: product.price)
//                iapProductPrice.append("\(price1Str ?? "Price Not Found")\(productionSubscriptionPeriod)" )
//            }
//            showViewContent()
//        } else {
//            DispatchQueue.main.async {
//                if !self.show1999Subscription() {
//                    self.fetchAllAvailableProducts(self.productIdentifier1999) //If we are supposed to show 999 but it is not avaialble yet, show 1999
//                } else {
//                    self.showAlertMessage(title: "Error", message: "Unable to load product. Please contact support.", needPlaceHolderText: nil, preferredStyle: .alert)
//                }
//            }
//        }
//        Spinner.stop()
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//        print("Error at restoring completed transations: \(error.localizedDescription)")
//        Spinner.stop()
//    }
//    
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        if queue.transactions.count == 0 {
//            Spinner.stop()
//            dimissAfterOkAction(title: "Restore Failed", message: "Nothing to restore")
//        }
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//            case .purchased:
//                complete(transaction: transaction)
//                break
//            case .failed:
//                fail(transaction: transaction)
//                break
//            case .restored:
//                restore(transaction: transaction)
//                break
//            case .deferred:
//                //Don't need to do anything since this app is 17+ there won't be any kids that need to ask parents for permission to purchase item.
//                break
//            case .purchasing:
//                break
//            }
//        }
//    }
//    
//    //Handle Completed Transaction
//    private func complete(transaction: SKPaymentTransaction) {
//        print("complete...")
//        setProductPurchased(identifier: transaction.payment.productIdentifier, transaction: transaction)
//        
//        SKPaymentQueue.default().finishTransaction(transaction)
//        Spinner.stop()
//        
//        if fromStoryboard {
//            self.goToHomeVC()
//        } else {
//            self.dismissVC()
//        }
//    }
//    
//    //Handle Restore Transaction
//    private func restore(transaction: SKPaymentTransaction) {
//        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
//        print("restore... \(productIdentifier)")
//        
//        if !isLifeTimePurchase {//once we hit one restore of unlimited, stop trying to get subscription -- edge should never happen.
//            setProductPurchased(identifier: productIdentifier, transaction: transaction)
//        }
//        
//        SKPaymentQueue.default().finishTransaction(transaction)
//        Spinner.stop()
//        dimissAfterOkAction(title: "You're all set.", message: "Your past purchase has been restored.")
//    }
//    
//    //Handle Failed Transaction
//    private func fail(transaction: SKPaymentTransaction) {
//        print("fail...")
//        if let transactionError = transaction.error as NSError?,
//            let localizedDescription = transaction.error?.localizedDescription,
//            transactionError.code != SKError.paymentCancelled.rawValue {
//            print("Transaction Error: \(localizedDescription)")
//        }
//        
//        SKPaymentQueue.default().finishTransaction(transaction)
//        Spinner.stop()
//    }
//    
//    //A Glorified function that basically sets user defaults to know whether a product is purchased and send the user an alert that the product is purchased.
//    private func setProductPurchased(identifier: String?, transaction: SKPaymentTransaction) {
//        guard let identifier = identifier else { return }
//        
//        //Grab current Transaction's Product ID
//        let transactionProductIdentifier = transaction.payment.productIdentifier
//        
//        if identifier == Constants.storeKitProductIdentiferLifetimeED { //ONLY RESTORE NOW
//            if let originalTransactionTimeInterval = transaction.original?.transactionDate?.timeIntervalSince1970,
//                //Get the currencyCode from StoreKit aka User's iTunes Currency
//                let userCurrencyCode = iapProducts.first?.priceLocale.currencyCode { //Currency is the same for any product
//
//                FirebaseNetworkService.addUserPurchaseActivity(timestamp: Int(originalTransactionTimeInterval),
//                                                               price: Int(truncating: 499),
//                                                               currencyCode: userCurrencyCode,
//                                                               identifier: transaction.payment.productIdentifier,
//                                                               title: productTitle,
//                                                               restore: true)
//
//
//                Analytics.logEvent("purchase_completed", parameters: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: 499), "duration": "ed_unlimited_1"])
//                FBSDKAppEvents.logEvent("purchase_completed", parameters: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: 499), "duration": "ed_unlimited_1"])
//                Mixpanel.mainInstance().track(event: "purchase_completed", properties: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: 499), "duration": "ed_unlimited_1"])
//                AppsFlyerTracker.shared()?.trackEvent("purchase_completed", withValues: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: 499), "duration": "ed_unlimited_1"])
//                
//                
//                isLifeTimePurchase = true
//                self.purchasedProductsId.insert(identifier)
//                self.getUserPurchaseDates(for: transaction.payment.productIdentifier)
//                UserDefaults.standard.set(true, forKey: Constants.storeKitProductIdentiferUnlockedED) //Will use this at Program to unlock timeline, we using the constants productidentifier becuase it is used throughout .
//                self.setPurchasedView()
//                self.delegation?.hasPurchased()
//            }
//        
//        } else if identifier == Constants.storeKitProductIdentiferUnlockedED || identifier == Constants.storeKitProductIdentiferUnlockedED2 {
//            //The product identifier restored is one of the products that is available in this app version
//            if let currentTransactionTimeInterval = transaction.transactionDate?.timeIntervalSince1970,
//                //Get product's display title from the fetched products at ViewDidLoad
//                let productTitle = iapProducts.filter({ $0.productIdentifier == identifier}).first?.localizedTitle,
//                //Get the currencyCode from StoreKit aka User's iTunes Currency
//                let userCurrencyCode = iapProducts.filter({ $0.productIdentifier == transactionProductIdentifier}).first?.priceLocale.currencyCode,
//                let subscriptionPeriod = iapProductPrice.first!.dropFirst().components(separatedBy: "/")[1] as? String,
//                //Get transaction price
//                let transactionPrice = iapProducts.filter({ $0.productIdentifier == transactionProductIdentifier}).first?.price {
//                
//                //from 149.99 to 14999
//                let transactionPriceNoDecimal = transactionPrice.multiplying(byPowerOf10: 2)
//                
//                //Checks to see if this is the original transaction
//                if transaction.original?.transactionDate?.timeIntervalSince1970 == nil {
//                   //First transactin aka user is purchasing
//                    FirebaseNetworkService.addUserPurchaseActivity(timestamp: Int(currentTransactionTimeInterval),
//                                                                   price: Int(truncating: transactionPriceNoDecimal),
//                                                                   currencyCode: userCurrencyCode, subscriptionUnit: subscriptionUnit,
//                                                                   identifier: transaction.payment.productIdentifier,
//                                                                   title: productTitle)
//                    
//                    Analytics.logEvent("purchase_completed", parameters: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: transactionPriceNoDecimal), "duration":subscriptionPeriod])
//                    FBSDKAppEvents.logEvent("purchase_completed", parameters: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: transactionPriceNoDecimal), "duration":subscriptionPeriod])
//                    Mixpanel.mainInstance().track(event: "purchase_completed", properties: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: transactionPriceNoDecimal), "duration":subscriptionPeriod])
//                    AppsFlyerTracker.shared()?.trackEvent("purchase_completed", withValues: ["purchase_id": transaction.payment.productIdentifier,"price": Int(truncating: transactionPriceNoDecimal), "duration":subscriptionPeriod])
//                    FBSDKAppEvents.logEvent(FBSDKAppEventNameSubscribe, parameters: ["\(FBSDKAppEventParameterNameOrderID)": transaction.transactionIdentifier, "\(FBSDKAppEventParameterNameCurrency)": userCurrencyCode])
//                    
//                    if !Constants.inDevelopment {
//                        let userAttributes = ICMUserAttributes()
//                        let customAttributes = ["purchase_completed": true]
//                        userAttributes.customAttributes = customAttributes
//
//                        Intercom.updateUser(userAttributes)
//                    }
//                    
//                    
//                    let user = Extensions.getUserFromUserDefaults()
//                    
//                    if let userID = user.userId {
//                        Extensions.appStoreReceiptValidation(userID: userID, productId: identifier,  { hasReceipt, date, receiptType in
//                            //We do not wait for the data; server will take care if user tries to restore and update the db.
//                        })
//                    }
//                    self.purchasedProductsId.insert(identifier)
//                    self.getUserPurchaseDates(for: transaction.payment.productIdentifier)
//                    UserDefaults.standard.set(true, forKey: identifier) //Will use this at Program to unlock timeline
//                    self.setPurchasedView()
//                    self.delegation?.hasPurchased()
//                } else {
//                    //User is restoring this product.
//                    //Get user's original transaction purchase timeintercal
//                    if let originalTransactionTimeInterval = transaction.original?.transactionDate?.timeIntervalSince1970 {
//                        let user = Extensions.getUserFromUserDefaults()
//                        
//                        if let userID = user.userId {
//                            //Make sure the receipt is valid if user presses restore past purchase.
//                            //Doing this relies on the fact that CRON Job and s2s notification is working. We cannot rely on receiptData because it takes too long on celluar which causes timeout.
//                            
//                            Extensions.appStoreReceiptValidation(userID: userID, productId: identifier, { hasReceipt, date, receiptType in
//                                if hasReceipt {
//                                    FirebaseNetworkService.isUserSubscribed({ isCompleted, isExpired in
//                                        if isCompleted {
//                                            if !isExpired {
//                                                FirebaseNetworkService.addUserPurchaseActivity(timestamp: Int(originalTransactionTimeInterval),
//                                                                                               price: Int(truncating: transactionPriceNoDecimal),
//                                                                                               currencyCode: userCurrencyCode, subscriptionUnit: self.subscriptionUnit,
//                                                                                               identifier: transaction.payment.productIdentifier,
//                                                                                               title: productTitle,
//                                                                                               restore: true)
//                                                
//                                                
//                                                self.purchasedProductsId.insert(identifier)
//                                                self.getUserPurchaseDates(for: transaction.payment.productIdentifier)
//                                                UserDefaults.standard.set(true, forKey: identifier) //Will use this at Program to unlock timeline
//                                                self.setPurchasedView()
//                                                self.delegation?.hasPurchased()
//                                            }
//                                        }
//                                    })
//                                }
//                            })
//                        }
//                    }
//                }
//                
//            }
//        }
//    }
//}
//
