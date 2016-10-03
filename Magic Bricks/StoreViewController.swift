//
//  StoreViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 2/16/16.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import StoreKit

class StoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var tableView = UITableView()
    let productIdentifiers = Set(["removeAds", "easyMode", "X2"])
    var product: SKProduct?
    var productsArray = Array<SKProduct>()
    
    var purchasedItems : [String] = []
    var highScore = Int()
    var removeAds = false
    var unlockEasyMode = false
    var activateX2 = false
    var x2 = false
    var activateEasyMode = false
    var activateHardMode = false
    var selectButtonColor = UIColor.black
    var secondSelectButton = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if activateX2 == true {
            x2 = true
        }
        
        print(highScore)
        
        tableView = UITableView(frame: self.view.frame)
        
        tableView.separatorColor = UIColor.clear
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        
        SKPaymentQueue.default().add(self)
        requestProductData()
        
        // saves high score and other booleans
        let defaults: UserDefaults = UserDefaults.standard
        defaults.set(unlockEasyMode, forKey: "unlockEasy")
        defaults.set(removeAds, forKey: "removeAds")
        defaults.set(activateX2, forKey: "X2")
        defaults.synchronize()
        print("Highscore: \(highScore)", ", UnlockEasyMode: \(unlockEasyMode)", ", X2: \(x2)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SKPaymentQueue.default().remove(self)
    }
    
    // In-App Purchase Methods
    
    func requestProductData()
    {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers:
                self.productIdentifiers as Set<String>)
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil
                {
                    UIApplication.shared.openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        var products = response.products
        
        if (products.count != 0) {
            for i in 0 ..< products.count
            {
                self.product = products[i] as SKProduct
                self.productsArray.append(product!)
            }
            self.tableView.reloadData()
        } else {
            print("No products found")
        }
        
        //products = response.invalidProductIdentifiers
        
        for product in products
        {
            print("Product not found: \(product)")
        }
    }
    
    func buyProduct(_ sender: UIButton) {
        let payment = SKPayment(product: productsArray[sender.tag])
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.purchased:
                print("Transaction Approved")
                print("Product Identifier: \(transaction.payment.productIdentifier)")
                self.deliverProduct(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.failed:
                print("Transaction Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func deliverProduct(_ transaction:SKPaymentTransaction) {
        
        if transaction.payment.productIdentifier == "removeAds"
        {
            print("Remove Ads delivered and Unlocked")
            // Unlock Feature
            removeAds = true
            print(removeAds)
        }
        else if transaction.payment.productIdentifier == "easyMode"
        {
            print("Easy Mode delivered and Unlocked")
            // Unlock Feature
            unlockEasyMode = true
            print(unlockEasyMode)
        }
        else if transaction.payment.productIdentifier == "X2"
        {
            print("X2 delivered and Unlocked")
            // Unlock Feature
            activateX2 = true
            x2 = true
            print(x2)
        }
    }
    
    func restorePurchases(_ sender: UIButton) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func closeStore(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GameOverVC", sender: nil) // allows for segues without a button
        let resultController = self.storyboard?.instantiateViewController(withIdentifier: "GameOverVC") as? GameOverViewController
        self.present(resultController!, animated: true, completion: nil)
        print("Closed")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Transactions Restored")
        
        var purchasedItemIDS : [String] = []
        for transaction:SKPaymentTransaction in queue.transactions {
            
            if transaction.payment.productIdentifier == "removeAds"
            {
                print("Remove Ads Restored")
                removeAds = true
                purchasedItemIDS.append("removeAds")
            }
            else if transaction.payment.productIdentifier == "easyMode"
            {
                print("Easy Mode Restored")
                unlockEasyMode = true
                purchasedItemIDS.append("easyMode")
            }
            else if transaction.payment.productIdentifier == "X2"
            {
                print("X2 Restored")
                activateX2 = true
                x2 = true
                purchasedItemIDS.append("X2")
            }
        }
        
        let alert = UIAlertView(title: "Thank You", message: "Your purchase(s) were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    // Screen Layout Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.productsArray.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellFrame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 52.0)
        let retCell = UITableViewCell(frame: cellFrame)
        
        if self.productsArray.count != 0
        {
            
            if (indexPath as NSIndexPath).row == 3
            {
                let restoreButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: UIScreen.main.bounds.width - 20.0, height: 44.0))
                restoreButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Bold", size: 25)
                restoreButton.addTarget(self, action: #selector(StoreViewController.restorePurchases(_:)), for: UIControlEvents.touchUpInside)
                restoreButton.backgroundColor = UIColor.purple
                restoreButton.setTitle("Restore Purchases", for: UIControlState())
                retCell.addSubview(restoreButton)
            }
            else if (indexPath as NSIndexPath).row == 4
            {
                let closeButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: UIScreen.main.bounds.width - 20.0, height: 44.0))
                closeButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Bold", size: 25)
                closeButton.addTarget(self, action: #selector(StoreViewController.closeStore(_:)), for: UIControlEvents.touchUpInside)
                closeButton.backgroundColor = UIColor.purple
                closeButton.setTitle("Close", for: UIControlState())
                retCell.addSubview(closeButton)
            }
            else
            {
                let singleProduct = productsArray[(indexPath as NSIndexPath).row]
                
                let titleLabel = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: UIScreen.main.bounds.width - 20.0, height: 25.0))
                titleLabel.textColor = UIColor.black
                titleLabel.text = singleProduct.localizedTitle
                titleLabel.font = UIFont (name: "HelveticaNeue", size: 20)
                retCell.addSubview(titleLabel)
                
                let descriptionLabel = UILabel(frame: CGRect(x: 10.0, y: 10.0, width: UIScreen.main.bounds.width - 70.0, height: 40.0))
                descriptionLabel.textColor = UIColor.black
                descriptionLabel.text = singleProduct.localizedDescription
                descriptionLabel.font = UIFont (name: "HelveticaNeue", size: 12)
                retCell.addSubview(descriptionLabel)
                
                let buyButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 60.0, y: 5.0, width: 50.0, height: 20.0))
                buyButton.titleLabel!.font = UIFont (name: "HelveticaNeue", size: 12)
                buyButton.tag = (indexPath as NSIndexPath).row
                buyButton.addTarget(self, action: #selector(StoreViewController.buyProduct(_:)), for: UIControlEvents.touchUpInside)
                buyButton.backgroundColor = UIColor.black
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = Locale.current
                buyButton.setTitle(numberFormatter.string(from: singleProduct.price), for: UIControlState())
                retCell.addSubview(buyButton)
            }
        }
        
        if self.productsArray.count == 0 {
            if (indexPath as NSIndexPath).row == 0
            {
                let restoreButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: UIScreen.main.bounds.width - 20.0, height: 44.0))
                restoreButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Bold", size: 25)
                restoreButton.addTarget(self, action: #selector(StoreViewController.restorePurchases(_:)), for: UIControlEvents.touchUpInside)
                restoreButton.backgroundColor = UIColor.purple
                restoreButton.setTitle("Restore Purchases", for: UIControlState())
                retCell.addSubview(restoreButton)
            }
            else if (indexPath as NSIndexPath).row == 1
            {
                let closeButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: UIScreen.main.bounds.width - 20.0, height: 44.0))
                closeButton.titleLabel!.font = UIFont (name: "HelveticaNeue-Bold", size: 25)
                closeButton.addTarget(self, action: #selector(StoreViewController.closeStore(_:)), for: UIControlEvents.touchUpInside)
                closeButton.backgroundColor = UIColor.purple
                closeButton.setTitle("Close", for: UIControlState())
                retCell.addSubview(closeButton)
            }

        }
        
        return retCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 52.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0
        {
            return 64.0
        }
        
        return 32.0
    }
    
    // Create Title for Store
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let ret = UILabel(frame: CGRect(x: 10, y: 0, width: self.tableView.frame.width - 20, height: 32.0))
        ret.backgroundColor = UIColor.clear
        ret.text = "Store"
        ret.textAlignment = NSTextAlignment.center
        return ret
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GameOverVC" {
            let svc = segue.destination as! GameOverViewController
            svc.removeAds = removeAds
            svc.highScore = highScore
            svc.unlockEasyMode = unlockEasyMode
            svc.activateEasyMode = activateEasyMode
            svc.activateHardMode = activateHardMode
            svc.x2 = x2
            svc.selectButtonColor = selectButtonColor
            svc.activateX2 = activateX2
        }
    }
}
