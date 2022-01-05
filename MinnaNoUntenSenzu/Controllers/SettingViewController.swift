//
//  SettingViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/02.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD


class SettingViewController: UIViewController {
    
    @IBOutlet weak var currentDisplayNameLabel: UILabel!
    
    @IBOutlet weak var displayNameTextField: UITextField!
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        self.navigationItem.title = "設定"
    }
    
    @objc func dismissKeyboard(){

        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = Auth.auth().currentUser
        if let user = user {
            currentDisplayNameLabel.text = "現在の表示名:" + user.displayName!
        }
    }
    
    @IBAction func handleChangeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text{
            
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "新しい表示名を入力してください")
                return
            }
            
            if let user = user{
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error{
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print(error.localizedDescription)
                        return
                    }
                    print("\(user.displayName!)]の設定に")
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました。")
                }
            }
        }

        self.view.endEditing(true)
    }
    
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.present(loginViewController!, animated: true, completion: nil)
        
        tabBarController?.selectedIndex = 0
    }
    
    
}
