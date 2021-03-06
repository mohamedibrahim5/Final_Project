//
//  cartViewController.swift
//  Merita
//
//  Created by mohamed ibrahim on 12/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import SDWebImage
import  NVActivityIndicatorView

class cartViewController: UIViewController {
    let indicator = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .systemRed, padding: 0)
    var userId : String?
    var valueArray: [String] = []
    var valueArrayprice: [String] = []
    var valueArrayimage: [String] = []
    var arrayOfProduct : [ProductCategory] = [ProductCategory]()
    let productCategoryViewModel = ProductsCategoryViewModel()
    var arrayTitle : [String] = []
    var totalOfPrice : [Double] = []
    var totalPrice2 : Double = 0
    var newTotalPrice : Double = 0
    var newTotalPrice2 : Double = 0
    var numberOfIndexPath : Int?
    var numberOfItems : Int = 0
    static var totall : Double = 0


    
    @IBOutlet weak var numberOfProduct: UILabel!
    @IBOutlet weak var shippingfee: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    var numItemInCell : Int = 1
   
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableview.refreshControl = UIRefreshControl ()
//        self.tableview.refreshControl?.addTarget(Self.self, action: #selector(self.didPullToFresh), for: .valueChanged)
        productCategoryViewModel.fetchProductCategory()
        productCategoryViewModel.bindingProductCategory = { productsCategory, error in
            if let productsCategory = productsCategory {
                self.arrayOfProduct = productsCategory
                DispatchQueue.main.async {
                    self.arrayTitle.removeAll()
                    for index in 0..<self.arrayOfProduct.count{
                        self.arrayTitle.append(self.arrayOfProduct[index].title!)
                        print(self.arrayTitle[index])
                    }
                }
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if userId != nil {
            self.showActivityIndicator(indicator: self.indicator, startIndicator: true)
                            let db = Firestore.firestore()
                    db.collection("Cart").document("\(self.userId!)").collection("all information").getDocuments { (snapshot, error) in
                        
                        if error == nil && snapshot != nil {
                            self.totalOfPrice.removeAll()
                            self.valueArrayimage.removeAll()
                            self.valueArray.removeAll()
                            self.valueArrayprice.removeAll()
                            for document in snapshot!.documents {
                            self.valueArray.append(document.data()["name"] as! String)
                            self.valueArrayprice.append(document.data()["price"] as! String)
                            self.valueArrayimage.append(document.data()["image"] as! String)
                            self.totalOfPrice.append(document.data()["DouplePrice"] as! Double)
                            self.totalPrice2 = 0
                                for index in 0..<self.valueArray.count {
                                    self.totalPrice2 = self.totalPrice2 + self.totalOfPrice[index]
                                }
                                print(self.totalPrice2)
                                self.totalPrice.text = "\(self.totalPrice2)"
                                cartViewController.totall = self.totalPrice2
                                print("koko\(cartViewController.totall)")
                              
                    }
                            self.tableview.reloadData()
                }
                        
            }
            self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
        }
      
}
    @IBAction func Cgeckout(_ sender: UIButton) {
        if userId != nil {
            if self.valueArray.count > 0 {
                let vc = UIStoryboard(name: "checkout", bundle: nil).instantiateViewController(withIdentifier: "check") as? CheckOut
                vc!.userId = userId
                let totalPricr = Double(totalPrice.text!)
                vc?.totalPrice = totalPricr
                self.navigationController!.pushViewController(vc!, animated: true)
            } else {
                emptyCart()
            }

        } else {
            loginAlert()
        }
        
    }
}


extension cartViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if valueArray.count == 0 {
            self.numberOfProduct.text = "0"
            self.totalPrice.text = "0"
        }
        return valueArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cartcell", for: indexPath) as! cartTableViewCell
        numberOfProduct.text = "\(valueArray.count)"
        cell.numberProductInCell.text = "1"
        cell.imageProduct.sd_setImage(with: URL(string: valueArrayimage[indexPath.row]))
        cell.nameProduct.text = valueArray[indexPath.row]
        cell.priceProduct.text = valueArrayprice[indexPath.row]
        cell.total.text = "\(totalOfPrice[indexPath.row])"
        var count = 1
        cell.plus = { [self] in
            count+=1
            if count > 3 {
                count =  3
                maxProduct()
            }
            else {
                let num : Double = totalOfPrice[indexPath.row]
                newTotalPrice = newTotalPrice + num
                let total = totalPrice2 + newTotalPrice
                cartViewController.totall = total
                totalPrice.text = "\(total)"
                cell.numberProductInCell.text = "\(count)"
                numberOfItems = numberOfItems+1
                numberOfProduct.text = "\(valueArray.count+numberOfItems)"
                cell.total.text = "\(Double(count) * totalOfPrice[indexPath.row])"
            }
               
            
            
        }
        cell.mines = { [self] in
            count-=1
            if count < 1 {
                count =  1
                minprodcut()
            }else {
                let num : Double = totalOfPrice[indexPath.row]
                newTotalPrice = newTotalPrice - num
                 let total = totalPrice2 + newTotalPrice
                cartViewController.totall = total
                totalPrice.text = "\(total)"
                cell.numberProductInCell.text = "\(count)"
                numberOfItems = numberOfItems-1
                numberOfProduct.text = "\(valueArray.count+numberOfItems)"
                cell.total.text = "\(Double(count) * totalOfPrice[indexPath.row])"
            }
           
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAtion = UIContextualAction(style: .destructive, title: "Delete") { action, view, complationHandler in
            self.showActivityIndicator(indicator: self.indicator, startIndicator: true)
            print(indexPath.row)
            print(self.valueArray[indexPath.row])
            let checkName = self.valueArray[indexPath.row]
            for i in 0..<self.arrayOfProduct.count{
                if checkName == self.arrayOfProduct[i].title {
                    self.numberOfIndexPath = i
                }
            }
            let db = Firestore.firestore()
            db.collection("Cart").document("\(self.userId!)").collection("all information").document("\(self.arrayOfProduct[self.numberOfIndexPath!].id!)").delete{ (error) in
                if error == nil {
                    print("delete is done ")
         //           self.totalPrice.text = "\(self.totalPrice2 - self.totalOfPrice[indexPath.row])$"
                } else {
                    print("delete is not done ")
                }
            }
            self.valueArray.remove(at: indexPath.row)
            self.valueArrayprice.remove(at: indexPath.row)
            self.valueArrayimage.remove(at: indexPath.row)
            self.tableview.beginUpdates()
            self.tableview.deleteRows(at: [indexPath], with: .automatic)
            self.tableview.endUpdates()
            complationHandler(true)
            self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
            let vc = UIStoryboard(name: "AddCartScreen", bundle: nil).instantiateViewController(withIdentifier: "cartcell") as? cartViewController
            vc!.userId = self.userId
            self.navigationController!.pushViewController(vc!, animated: true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAtion])
    }
    
    
}


extension cartViewController {
    func maxProduct (){
        let alert = UIAlertController(title: "Sorry", message: "the Maximum number of order is 3 ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
}
    func minprodcut (){
        let alert = UIAlertController(title: "Sorry", message: "the Minmim number  of order must  be 1 you can delete it from orders ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
}
    @objc private func didPullToFresh(){
        print("staart refreshing")
        DispatchQueue.main.async {
            self.tableview.refreshControl?.endRefreshing()
        }
    }
    func emptyCart(){
        let alert = UIAlertController(title: "Sorry", message: "you cart is empty ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
}

    
}
