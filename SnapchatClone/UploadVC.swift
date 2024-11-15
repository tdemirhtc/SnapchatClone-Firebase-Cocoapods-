//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Hatice Taşdemir on 30.10.2024.
//

import UIKit
import Firebase

class UploadVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        
        super.viewDidLoad()

        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePic))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
       @objc func choosePic(){
            let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = .photoLibrary
           self.present(picker, animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
            
    
    
                                                       
                                                       
                                                       
    

    @IBAction func uploadClicked(_ sender: Any) {
        
        //storage
        let storage = Storage.storage()
        let storagereference = storage.reference()
        
        //görselleri nereye koyacağımıza karar verdiğimiz klasör
        let mediaFolder = storagereference.child("media")
        //görseli veriye çevirir
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            //görsele isim verir o isimle kayıt eder.
            let uuid = UUID().uuidString
            
           // kayıt etmek için imagereference oluşşturulkur
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data, metadata: nil) { (metadata,error) in
                if error != nil {
                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                    
                }else{
                    //upload işlemi doğru düzgün yapılırsa:
                    imageReference.downloadURL { url, error in
                        if error == nil{
                            let imageUrl = url?.absoluteString
                            
                            //firebase kayıt etmek:
                            
                            let fireStore = Firestore.firestore()
                            
                            //kayıt etmeden önce attığı snap veri var mı yok mu kontrolü:
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: userSingleton.sharedUserInfo.username).getDocuments { snapshot, error in
                                if error != nil {
                                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                                }else{
                                    if snapshot?.isEmpty == false && snapshot != nil {
                                        for document in snapshot!.documents {
                                            //daha önceki dökümanın içinde işlem yapmak için yeni snap eklendiğinde yeni doc açmasın aynı doca yazsın diye docId alınır
                                            let docId = document.documentID
                                            //eğer veri varsa imageurl eklenecek
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] {
                                                imageUrlArray.append(imageUrl!)
                                                //tekrar kayıt edeceğiz aynı doc.a
                                                let additionalDic = ["imageUrlArray" : imageUrlArray] as [String : Any]
                                                //merge eski değerleri tut üstüne ekle demek
                                                fireStore.collection("Snaps").document(docId).setData(additionalDic, merge: true) { (error) in
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.imageView.image = UIImage(named: "selectedimage.png")
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            
                            
                            // ne kayıt edeceğimizi dictionary olarak vermek için:
                            let snapDict = ["imageUrlArray" : [imageUrl!], "snapOwner" : userSingleton.sharedUserInfo.username, "date" : FieldValue.serverTimestamp()]
                            as [String : Any]
                           
                            fireStore.collection("Snaps").addDocument(data: snapDict) { error in
                                if error != nil {
                                    self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                                }else{
                                    self.tabBarController?.selectedIndex = 0
                                    self.imageView.image = UIImage(named: "selectimage.png")
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
        
        
    }
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

