//
//  TableViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/05.
//

import UIKit
import FirebaseFirestore
import Firebase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var idString: String!
    var untenKirokuArray = [UntenKiroku]()
    var listener: ListenerRegistration?
  
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        overrideUserInterfaceStyle = .light
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if untenKirokuArray.count == 0{
            loadData()
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let titleLabel = cell.contentView.viewWithTag(1) as! UILabel
        let untenJihunLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        titleLabel.text = untenKirokuArray[indexPath.row].title
        untenJihunLabel.text = untenKirokuArray[indexPath.row].untenJifun
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return untenKirokuArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let runCurveVC = self.storyboard?.instantiateViewController(withIdentifier: "RunCurveVC") as! RunCurveViewController
        runCurveVC.untenKiroku = untenKirokuArray[indexPath.row]
        navigationController?.pushViewController(runCurveVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func loadData(){
        if Auth.auth().currentUser != nil {
            let postsRef = Firestore.firestore().collection("posts").document(idString!).collection("UntenKiroku").order(by: "date", descending: false)
            listener = postsRef.addSnapshotListener() {(querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                if let snapShotDoc = querySnapshot?.documents{
                    for doc in snapShotDoc{
                        let data = doc.data()
                        if let retsuban = data["retsuban"] as? Int, let title = data["title"] as? String, let date = data["date"] as? Double, let untenJifun = data["untenJifun"] as? String, let maxVelocity = data["maxVelocity"] as? Double, let latitudeArray = data["latitudeArray"] as? [Double], let longitudeArray = data["longitudeArray"] as? [Double], let velocityArray = data["velocityArray"] as? [Double]{
                            
                            let untenKiroku = UntenKiroku(retsuban: retsuban, title: title, date: date, untenJifun: untenJifun, maxVelocity: maxVelocity, latitudeArray: latitudeArray, longitudeArray: longitudeArray, velocityArray: velocityArray)
                            self.untenKirokuArray.append(untenKiroku)
                        }
                    }
                }
                print(self.untenKirokuArray.count)
                self.tableView.reloadData()
            }
        }
    }
}
