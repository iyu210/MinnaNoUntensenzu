//
//  PostData.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/06.
//

import Foundation
import Firebase

class PostData: NSObject{
    var id = String()
    var userID = String()
    var userName = String()
    var retsuban = String()
    var title = String()
    var date = String()
    
    init(id: String, userID: String, userName: String, title: String, retsuban: String, date: String){
        self.id = id
        self.userID = userID
        self.title = title
        self.retsuban = retsuban
        self.userName = userName
        self.date = date
    }

}
