//
//  SettingsVC.swift
//  SnapchatClone
//
//  Created by Hatice Taşdemir on 30.10.2024.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    
   //logout bir hata atan metot old. için do try catch yapılır.

    @IBAction func logoutClicked(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()

            self.performSegue(withIdentifier: "toSiginVC", sender: nil)

               }catch{

               }
      
    }
}
