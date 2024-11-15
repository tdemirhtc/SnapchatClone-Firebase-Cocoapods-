//
//  FeedVC.swift
//  SnapchatClone
//
//  Created by Hatice Taşdemir on 30.10.2024.
//

import UIKit
import Firebase
import SDWebImage



class FeedVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    
    let fireStoreDatabase = Firestore.firestore()
    var snapArray = [Snap]()
    var chosenSnap : Snap?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getSnapsFromFirebase()
        
        getUserInfo()
    }
    
    func getSnapsFromFirebase() {
        fireStoreDatabase.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil {
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
            }else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    self.snapArray.removeAll(keepingCapacity: false)
                    for document in snapshot!.documents {
                        
                        let docId = document.documentID
                        
                        if let username = document.get("snapOwner") as? String {
                            if let imageUrlArray = document.get("imageUrlArray") as? [String] {
                                if let date = document.get("date") as? Timestamp {
                                    
                                    //storyden kalan zamanı gösterme:(saatler günler aylar karşılaştırılacaksa calendar kullanılır)
                                    if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
                                        if difference >= 24 {
                                            self.fireStoreDatabase.collection("Snaps").document(docId).delete { (error) in
                                                
                                            }
                                        }
                                    }
                                        
                                    
                                    let snap = Snap(username: username, imageUrlArray: imageUrlArray, date: date.dateValue())
                                    //tableviewe alacağımızdan dolayı snap array tanımlarız.
                                    self.snapArray.append(snap)
                                }
                            }
                        }
                      
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    func getUserInfo() {
        fireStoreDatabase.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
            if error != nil {
                self.makeAlert(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
            }else{
                if snapshot?.isEmpty == false && snapshot != nil{
                    for document in snapshot!.documents{
                        if let username = document.get("username") as? String {
                            userSingleton.sharedUserInfo.email = (Auth.auth().currentUser?.email!)!
                            userSingleton.sharedUserInfo.username = username
                            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
        cell.usernameCell.text = snapArray[indexPath.row].username
        //bir dizi verecek.
        cell.feedImageView.sd_setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
      
        return cell
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toSnapVC" {
               
               let destinationVC = segue.destination as! SnapVC
               destinationVC.selectedSnap = chosenSnap
               
           }
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           chosenSnap = self.snapArray[indexPath.row]
           performSegue(withIdentifier: "toSnapVC", sender: nil)
       }

   

}
