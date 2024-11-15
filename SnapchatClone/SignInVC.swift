//
//  ViewController.swift
//  SnapchatClone
//
//  Created by Hatice Taşdemir on 30.10.2024.
//

import UIKit
import Firebase

class SignInVC: UIViewController {
    
    
    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func signinClicked(_ sender: Any) {
        if passwordText.text != "" && emailText.text != "" {
            
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { result, error in
                if error != nil{
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else{
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
        }else{
            self.makeAlert(titleInput: "error", messageInput: "Password/Email ?")
        }
    }

    
    @IBAction func signupClicked(_ sender: Any) {
        if usernameText.text != "" && passwordText.text != "" && emailText.text != "" {
            //eğer kullanıcı bilgileri verdiyse auth :
            Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { auth, error in
                if error != nil{
                    //hata boş değilse yani hata var ise:
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                }else{
                    //kullanıcı bilgilerini firestore'a kayıt etmek için çağırırız
                    let fireStore = Firestore.firestore()
                   // neyi kayıt edeceğimizi array değişkenine atarız collection doküman kısımında ekleriz.
                    let userDictionary = ["email":self.emailText.text!,"username":self.usernameText.text!] as [String : Any]
                    
                    
                    //hangi collection içine koyacağımızı kodlarız:ve hangi dökümana ekleyeceğimizi
                    fireStore.collection("UserInfo").addDocument(data: userDictionary) { (error) in
                        if error != nil{
                            
                        }
                    }
                    self.performSegue(withIdentifier: "toFeedVC", sender: nil)
                }
            }
            
        }else{
            self.makeAlert(titleInput: "error", messageInput: "username/password/email ?")
            
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

