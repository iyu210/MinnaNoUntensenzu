//
//  TabBarController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/02.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        overrideUserInterfaceStyle = .light
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil{
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginVC!, animated: true, completion: nil)
        }
    }
}
