//
//  MyRecordeViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/11/01.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MyRecordeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var postArray = [PostData]()
    var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "自分の運転線図"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMyData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        let userNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let backImage = cell.contentView.viewWithTag(2) as! UIImageView
        let titleLabel = cell.contentView.viewWithTag(3) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(4) as! UILabel
        
        if postArray.count != 0{
            userNameLabel.text = postArray[indexPath.row].userName
            titleLabel.text = postArray[indexPath.row].title
            dateLabel.text = postArray[indexPath.row].date
            
            if postArray[indexPath.row].retsuban == "6522" || postArray[indexPath.row].retsuban == "6527" || postArray[indexPath.row].retsuban == "6524" || postArray[indexPath.row].retsuban == "6529"{
                backImage.image = UIImage(named: "787")
            }else if  postArray[indexPath.row].retsuban == "722" || postArray[indexPath.row].retsuban == "731" ||  postArray[indexPath.row].retsuban == "730" || postArray[indexPath.row].retsuban == "739" ||  postArray[indexPath.row].retsuban == "6523" || postArray[indexPath.row].retsuban == "727" ||  postArray[indexPath.row].retsuban == "6532" || postArray[indexPath.row].retsuban == "6531" ||  postArray[indexPath.row].retsuban == "6526" || postArray[indexPath.row].retsuban == "6533" ||  postArray[indexPath.row].retsuban == "6528" || postArray[indexPath.row].retsuban == "6535" ||  postArray[indexPath.row].retsuban == "6530" || postArray[indexPath.row].retsuban == "6537" ||  postArray[indexPath.row].retsuban == "742" || postArray[indexPath.row].retsuban == "747" ||  postArray[indexPath.row].retsuban == "748" || postArray[indexPath.row].retsuban == "757"{
                
                backImage.image = UIImage(named: "713")
                
            }else {
                backImage.image = UIImage(named: "817")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableVC = self.storyboard?.instantiateViewController(withIdentifier: "TableVC") as! TableViewController
        tableVC.idString = postArray[indexPath.row].id
        navigationController?.pushViewController(tableVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //サブコレクションはしばらくコンソールから削除すること
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let docID = postArray[indexPath.row].id
        let db = Firestore.firestore()
        db.collection("posts").document(docID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        postArray.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func loadMyData(){
        
        postArray = []
        if Auth.auth().currentUser != nil{
            let postRef = Firestore.firestore().collection("posts").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid as Any).order(by: "time", descending: true)
            listener = postRef.addSnapshotListener() { snapShot, error in
                if let error = error{
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                
                if let snapShotDoc = snapShot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        if let title = data["title"] as? String, let userID = data["userID"] as? String, let retsuban = data["retsuban"] as? String, let date = data["postDate"] as? String, let userName = data["userName"] as? String{
                            self.postArray.append(PostData(id: doc.documentID, userID: userID, userName: userName, title: title, retsuban: retsuban, date: date))
                        }
                    }
                }
                self.tableView.reloadData()
            }
            
        }
    }
}

