//
//  LoginViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/02.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import CoreLocation

class LoginViewController: UIViewController {
    
    var alertController: UIAlertController!
    let locationManager = CLLocationManager()
    fileprivate var currentNonce: String?
    
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 位置情報利用許可ステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("authorized")
            // 許可しているとき
        case .denied:
            print("denied")
            // 許可していないとき
        case .notDetermined:
            // 許可を一度も取っていないとき
            locationManager.requestWhenInUseAuthorization()
            
        default:
            break
        }
        
    }
    
    @objc func dismissKeyboard(){
        
        view.endEditing(true)
    }
    
    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        
        present(alertController, animated: true)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if let number = numberTextField.text, let password = passwordTextField.text{
            if number.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: number, password: password) { authResult, error in
                if let error = error{
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("ログイン成功")
                SVProgressHUD.dismiss()
                
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    
    @IBAction func createAccountButton(_ sender: Any) {
        
        if let number = numberTextField.text, let password = passwordTextField.text, let displayName = displayTextField.text{
            
            if number.isEmpty || password.isEmpty || displayName.isEmpty{
                alert(title: "エラー",
                      message: "空白の入力欄があります。")
            }
            
            Auth.auth().createUser(withEmail: number, password: password) { authResult, error in
                if let error = error{
                    print("＝＝＝＝＝＝アカウント作成エラー＝＝＝＝＝＝＝＝")
                    print(error.localizedDescription)
                    print("=========アカウント作成エラー============")
                    return
                }
                print("アカウント作成終了")
                
                
                let user = Auth.auth().currentUser
                if let user = user{
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error{
                            print("＝＝＝＝＝＝表示名作成エラー＝＝＝＝＝＝＝＝")
                            print(error.localizedDescription)
                            print("=========表示名作成エラー============")
                            return
                        }
                        print("アカウント表示名\(user.displayName!)登録終了")
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
