//
//  HomePageScreanTabBarController.swift
//  Merita
//
//  Created by mohamed ibrahim on 11/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import  NVActivityIndicatorView
class HomePageScreanTabBarController: UITabBarController {
    var id :String?
    let indicator = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .systemRed, padding: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        
         id = UserDefaults.standard.string(forKey: "Login1")
        if id != nil {
            let mevc = self.viewControllers![3] as! meViewController
            mevc.userId = id!
            let homevc = self.viewControllers![0] as! HomePageViewC
            homevc.userId = id!
            let searchvc = self.viewControllers![1] as! GlobalSearchForProductsVC
            searchvc.userId = id!
            let cartvc = self.viewControllers![2] as! cartViewController
            cartvc.userId = id!
            scheduleNotifiction(title: "Welcome! we hope you enjoyed ", identifir: "\(id!)")
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action:  #selector(signOut(_:)))
        }else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .done, target: self, action:  #selector(signOut(_:)))
        }
        
    }
    @IBAction func signOut(_ sender: AnyObject) {
        if id != nil {
            self.showActivityIndicator(indicator: self.indicator, startIndicator: true)
            let alert = UIAlertController(title: "Warning", message: "Are you want to sign out ", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
                UserDefaults.standard.set(false, forKey: "Login")
                UserDefaults.standard.set(nil, forKey: "Login1")
                self.navigationController?.popViewController(animated: true)
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.showActivityIndicator(indicator: self.indicator, startIndicator: false)
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }else {
            let vc = UIStoryboard(name: "LoginScreen", bundle: nil).instantiateViewController(withIdentifier: "celllogin") as? LoginScreenViewController
            navigationController?.pushViewController(vc!, animated: true)
        }
        
    }

}


extension HomePageScreanTabBarController {
    func scheduleNotifiction(title:String,identifir:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.badge = 0
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(3), repeats: false)
      let request = UNNotificationRequest(identifier: identifir, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
