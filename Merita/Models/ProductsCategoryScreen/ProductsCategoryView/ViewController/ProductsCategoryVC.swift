//
//  ViewController.swift
//  Merita
//
//  Created by ahmed rabie on 01/07/2022.
//

import UIKit

class ProductsCategoryVC: UIViewController {
    
    @IBOutlet weak var productCategoryCView: UICollectionView!{
        didSet{
            productCategoryCView.dataSource = self
            productCategoryCView.delegate = self
            productCategoryCView.backgroundView?.backgroundColor = UIColor.clear
            productCategoryCView.backgroundColor = UIColor.clear
        }
    }
    
    var arrayOfProducts = [ProductCategory]()
    let productCategoryViewModel = ProductsCategoryViewModel()
    
    var categoryTitle: String?
    var brandTitle: String?
    var arrayOfProductsCategory = [ProductCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productCategoryViewModel.fetchProductCategory()
        productCategoryViewModel.bindingProductCategory = { productsCategory, error in
            if let productsCategory = productsCategory {
                self.arrayOfProducts = productsCategory
                DispatchQueue.main.async {
                    self.productCategoryCView.reloadData()
                }
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
}


extension ProductsCategoryVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        for category in self.arrayOfProducts {
            if let tags = category.tags{
                let string = tags
                if let categoryTitle = self.categoryTitle {
                    if string.lowercased().contains(categoryTitle.lowercased()) {
                        print("TitleCategory in viewDidLoad found")
                        print("TitleCategory in view: \(category.title?.lowercased() ?? "hossam")")
                        arrayOfProductsCategory.append(category)
                        
                    }
                    
                }
                
            }
        }
        
        for category in self.arrayOfProducts {
            if let vendor = category.vendor{
                if let brandTitle = brandTitle{
                    if vendor == brandTitle {
                        print("\(vendor) == \(brandTitle)")
                        arrayOfProductsCategory.append(category)
                    }
                }
                
            }
        }
        
        print("TitleCategory count  \(arrayOfProductsCategory.count)")
        return arrayOfProductsCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellProductsCategory = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCViewCell", for: indexPath) as! ProductCategoryCViewCell
        
        
        let productCategoryDetails = arrayOfProductsCategory[indexPath.row]
        
        //MARK: -  Return Products In Category
        if let tags = productCategoryDetails.tags{
            
            let string = tags
            if let cTitle = categoryTitle{
                if string.lowercased().contains(cTitle.lowercased()) {
                    print("TitleCategory found")
                    
                    cellProductsCategory.configureProductCategoryCell(imageProduct: productCategoryDetails.images?[0].src ?? "", titleProduct: productCategoryDetails.title ?? "", priceProduct: productCategoryDetails.variants?[0].price ?? "")
                    
                }
            }
        }
        //MARK: - Return Products in Brand
        if let vendor = productCategoryDetails.vendor{
            if let brandTitle = brandTitle{
                if vendor == brandTitle {
                    print("\(vendor) == \(brandTitle)")
                    
                    cellProductsCategory.configureProductCategoryCell(imageProduct: productCategoryDetails.images?[0].src ?? "", titleProduct: productCategoryDetails.title ?? "", priceProduct: productCategoryDetails.variants?[0].price ?? "")
                    
                }
            }
            
        }
        
        
        return cellProductsCategory
    }
    
    
}


//MARK: - Extension for UICollectionViewDelegate

extension ProductsCategoryVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let leftAndRightPaddings: CGFloat = 10
        let numberOfItemsPerRow: CGFloat = 5.0
        
        let width = (collectionView.frame.width-leftAndRightPaddings)/numberOfItemsPerRow
        return CGSize(width: width, height: width) // You can change width and height here as pr your requirement
        
    }
    
}

