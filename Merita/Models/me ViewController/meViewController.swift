//
//  meViewController.swift
//  Merita
//
//  Created by mohamed ibrahim on 06/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import SDWebImage
import  NVActivityIndicatorView

class meViewController: UIViewController {
    let indicator = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .systemRed, padding: 0)
    var arrFav : Dictionary<String, Any>?
    var arrayPrice2 : [String] = []
    var arrayName : [String] = []
    var arrImage : [String] = []
    var valueArrayimage : [String] = []
    var valueArrayprice : [String] = []
    var valueArray : [String] = []
    var arrayOfProduct = [ProductCategory]()
    let productCategoryViewModel = ProductsCategoryViewModel()
    var arrayTitle : [String] = []
    var numberOfIndexPath : Int?
    var arrayTptalPrice : [Double] = []
    var arrayTime : [String] = []
    var arrayAddress : [String] = []
   
    @IBOutlet weak var wishListTableview: UITableView!{
        didSet{
            wishListTableview.dataSource = self
            wishListTableview.delegate = self
        }
    }
    
    @IBOutlet weak var orderTableView: UITableView?{
        didSet{
            orderTableView?.dataSource = self
            orderTableView?.delegate = self
        }
    }
    
    @IBAction func settings(_ sender: UIBarButtonItem) {
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "setting") as? settings
        vc?.userId = userId
        
        self.navigationController!.pushViewController(vc!, animated: true)
    }
    
    @IBAction func cart(_ sender: UIBarButtonItem) {
        print("ordersMore")
        let vc = UIStoryboard(name: "AddCartScreen", bundle: nil).instantiateViewController(withIdentifier: "cartcell") as? cartViewController
        vc!.userId = userId
        self.navigationController!.pushViewController(vc!, animated: true)
        
    }
    @IBAction func washListMore(_ sender: UIButton) {
        print("washListMore")
        let vc = UIStoryboard(name: "Favourite Screen", bundle: nil).instantiateViewController(withIdentifier: "cell2") as? FavouriteScreenViewController
        vc!.userId = userId
        self.navigationController!.pushViewController(vc!, animated: true)
    }
   
    @IBAction func ordersMore(_ sender: UIButton) {
       
    }
    @IBOutlet weak var welcome: UILabel!
    var userId : String?
    @IBOutlet weak var nameOfCustomer: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderTableView?.register(UINib(nibName: "OredrTVCell", bundle: nil), forCellReuseIdentifier: "OredrTVCell")
        
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
        self.showActivityIndicator(indicator: self.indicator, startIndicator: true)
        let db = Firestore.firestore()
        let docRef = db.collection("customerinformation").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.welcome.text = "Welcome"
                self.nameOfCustomer.text = document["name"] as? String
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
            } else {
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
                print("Document does not exist")
            }
        }

        db.collection("FAV").document("\(self.userId!)").collection("all information").getDocuments { (snapshot, error) in
            
            if error == nil && snapshot != nil {
                self.valueArrayimage.removeAll()
                self.valueArray.removeAll()
                self.valueArrayprice.removeAll()
                for document in snapshot!.documents {
                self.valueArray.append(document.data()["name"] as! String)
                self.valueArrayprice.append(document.data()["price"] as! String)
                self.valueArrayimage.append(document.data()["image"] as! String)
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
               
                  
        }
                
                self.wishListTableview.reloadData()
              
        }
            
        }
        
        db.collection("order").document("\(self.userId!)").collection("all information").getDocuments { (snapshot, error) in
            
            if error == nil && snapshot != nil {
                self.arrayTime.removeAll()
                self.arrayAddress.removeAll()
                self.arrayTptalPrice.removeAll()
                for document in snapshot!.documents {
                self.arrayTime.append(document.data()["time"] as! String)
                self.arrayTptalPrice.append(document.data()["price"] as! Double)
                self.arrayAddress.append(document.data()["address"] as! String)
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
               
                  
        }
                
               // self.tableview.reloadData()
              
        }
            print("address \(self.arrayAddress)")

        }
}
}

extension meViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch tableView {
        case orderTableView:
            print("address = TableViewTop")
            if arrayAddress.count > 2 {
                return 2
            }else{
                return arrayAddress.count
            }
        case wishListTableview:
            print("address = TableviewBotton")
            if valueArray.count  > 2 {
                return 2
            } else {
                return valueArray.count
            }
            
        default:
            print("Somthig wrong")
            return 1
        }
        /*
        if tableView ==  orderTableView {
            if arrayAddress.count > 2 {
                return 2
            }else{
                return arrayAddress.count
            }
        }
        
    
        if valueArray.count  > 2 {
            return 2
        } else {
            return valueArray.count
        }
        */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellDame = UITableViewCell()
        switch tableView {
        case orderTableView:
            
            let orderCell = tableView.dequeueReusableCell(withIdentifier: "OredrTVCell", for: indexPath) as! OredrTVCell
            
            print("address \(arrayAddress)")
            print("address = TableViewTop")

            orderCell.address.text = arrayAddress[indexPath.row]
            orderCell.price.text = "\(arrayTptalPrice[indexPath.row])$"
            orderCell.date.text = arrayTime[indexPath.row]
            
        return orderCell
            
        case wishListTableview:
            let cell = tableView.dequeueReusableCell(withIdentifier: "washlistcell", for: indexPath) as! meWashListTableViewCell
            print("address = TableviewBotton")

            let index = indexPath.row
            cell.nameOfProduct.text = "\(valueArrayprice[index])$"
            cell.imageview.sd_setImage(with: URL(string: valueArrayimage[index]))
            cell.name.text = valueArray[index]
            return cell
        default:
            return cellDame
        }
        /*
         if tableView == orderTableView{
             let orderCell = tableView.dequeueReusableCell(withIdentifier: "meOrderTableViewCell", for: indexPath) as! meOrderTableViewCell
             
             print("address \(arrayAddress)")
             
             orderCell.adressOrder.text = arrayAddress[indexPath.row]
             orderCell.priceOrder.text = "\(arrayTptalPrice[indexPath.row])$"
             orderCell.dateOrder.text = arrayTime[indexPath.row]
             
         return orderCell
         }
         
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "washlistcell", for: indexPath) as! meWashListTableViewCell
         let index = indexPath.row
         cell.nameOfProduct.text = "\(valueArrayprice[index])$"
         cell.imageview.sd_setImage(with: URL(string: valueArrayimage[index]))
         cell.name.text = valueArray[index]
         return cell
         
         */
       
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "ProductInfo", bundle: nil).instantiateViewController(withIdentifier: "cell") as? productInfoViewController
        let checkName = valueArray[indexPath.row]
        for i in 0..<arrayOfProduct.count{
            if checkName == arrayOfProduct[i].title {
                numberOfIndexPath = i
            }
        }
        vc?.userId = userId
        vc?.arrayOfProducts = arrayOfProduct[numberOfIndexPath!]
        UserDefaults.standard.set(self.arrayOfProduct[numberOfIndexPath!].id, forKey: "fill")
        self.navigationController!.pushViewController(vc!, animated: true)
    }
}
