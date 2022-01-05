//
//  UntenKiroku.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/06.
//

import Foundation

class UntenKiroku: NSObject{
    
    var retsuban = Int()
    var title = String()
    var date = Double()
    var untenJifun = String()
    var maxVelocity = Double()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var velocityArray =  [Double]()
    
    init(retsuban: Int, title: String, date: Double, untenJifun: String, maxVelocity: Double,latitudeArray: [Double], longitudeArray: [Double], velocityArray: [Double]){
        self.retsuban = retsuban
        self.title = title
        self.date = date
        self.untenJifun = untenJifun
        self.maxVelocity = maxVelocity
        self.latitudeArray = latitudeArray
        self.longitudeArray = longitudeArray
        self.velocityArray = velocityArray
    }
    
}
