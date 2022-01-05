//
//  MeasuringViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/06.
//

import UIKit
import Charts
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

class MeasuringViewController: UIViewController, CLLocationManagerDelegate{
    
    var locationManager = CLLocationManager()
    var alertController: UIAlertController!
    var chartView: LineChartView!
    var chartDataSet: LineChartDataSet!
    var untenKiroku: UntenKiroku?
    var untenKirokuArray = [UntenKiroku]()
    var velocityArray = [Double]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var currentStation = String()
    var depStation = String()
    var currentVelocity = Double()
    var maxVelocity = 0.0
    var currentLatitude = Double()
    var currentLongitude = Double()
    var startDate = Date()
    var docID = String()
    var retsuban = Int()
    var stationCount = Int()
    var timer = Timer()
    var timerSet = false
    var measuring = false
    let stationArray = ["宮崎空港","田吉","南宮崎","宮崎","宮崎神宮","蓮ケ池","日向住吉","佐土原","日向新富","高鍋","川南","都農","東都農","美々津","南日向","財光寺","日向市","門川","土々呂","旭ヶ丘","南延岡","延岡"]
    var finalStationCount = Int()
    var documentPath = String()
    
    @IBOutlet weak var keisokuLabal: UILabel!
    @IBOutlet weak var currentVelocityLabel: UILabel!
    @IBOutlet weak var maxVelocityLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        overrideUserInterfaceStyle = .light
        UIApplication.shared.isIdleTimerDisabled = true
        chartView = LineChartView(frame: CGRect(x: 20, y: 0, width: view.frame.width - 20, height: view.frame.height / 2))
        view.addSubview(chartView)
        displayChart(data: velocityArray)
        startCreatingRunCurve()
        currentVelocityLabel.text = "速度: 0km/h"
        maxVelocityLabel.text = "最高速度: 0km/h"
    }
    
    @objc func updateVelocityArray(){
        let velocity = round(self.currentVelocity * 10) / 10
        if velocity > maxVelocity{
            self.maxVelocity = velocity
            maxVelocityLabel.text = "最高速度: \(self.maxVelocity)km/h"
        }
        currentVelocityLabel.text = "速度: \(velocity)km/h"
        velocityArray.append(velocity)
        latitudeArray.append(currentLatitude)
        longitudeArray.append(currentLongitude)
        chartView.removeFromSuperview()
        view.addSubview(chartView)
        displayChart(data: velocityArray)
    }
    
    @IBAction func stopAndPostButton(_ sender: Any) {
        if self.untenKirokuArray.count != 0 {
            stopCreatingRunCurve(data: untenKirokuArray)
        }else{
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func startCreatingRunCurve(){
        velocityArray = []
        latitudeArray = []
        longitudeArray = []
    }
    
    func stopCreatingRunCurve(data: [UntenKiroku]) {
        
        SVProgressHUD.show()
        backButton.isEnabled = false
        backButton.backgroundColor = .lightGray
        
        timer.invalidate()
        locationManager.stopUpdatingLocation()
        
        let userName = Auth.auth().currentUser?.displayName
        let date = Date()
        let dateFormat1 = DateFormatter()
        dateFormat1.dateFormat = "yyyyMMdd"
        let dateFormat2 = DateFormatter()
        dateFormat2.dateFormat = DateFormatter.dateFormat(fromTemplate: "ydMM", options: 0, locale: Locale(identifier: "ja_JP"))
        
        let retsubanText = String(retsuban)
        let docID = dateFormat1.string(from: date) + retsubanText
        let postData = PostData(id: docID, userID: Auth.auth().currentUser!.uid, userName: userName!, title: retsubanText + "Mの運転記録", retsuban: retsubanText, date: dateFormat2.string(from: date))
        
        Firestore.firestore().collection("posts").document(docID).setData(["userID": Auth.auth().currentUser?.uid as Any, "title":postData.title as Any, "retsuban" :postData.retsuban as Any, "userName": postData.userName as Any, "postDate": postData.date as Any, "time": Date().timeIntervalSince1970 as Any], merge: true, completion: { error in
            if let error = error{
                print("postsへのドキュメントの作成に失敗しました。\(error)")
            }else{
                print("postsへのドキュメントの作成に成功しました。ID: \(docID)")
            }
        })
        
        for untenData in data{
            let db = Firestore.firestore()
            db.collection("posts").document(docID).collection("UntenKiroku").addDocument(data: ["retsuban" : untenData.retsuban as Any, "title": untenData.title as Any, "date": untenData.date as Any, "untenJifun": untenData.untenJifun as Any, "maxVelocity": untenData.maxVelocity as Any, "latitudeArray": untenData.latitudeArray as Any, "longitudeArray": untenData.longitudeArray as Any, "velocityArray": untenData.velocityArray as Any])
        }
        SVProgressHUD.dismiss()
        self.untenKirokuArray = []
        self.navigationController?.popViewController(animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
            return
        }
        if newLocation.speed > 0 {
            self.currentVelocityLabel.text = "速度: \(round(newLocation.speed * 3.6 * 10) / 10)km/h"
        }
        let recognizeStation = recognizeStation(lat: newLocation.coordinate.latitude, log: newLocation.coordinate.longitude)
        //発車(計測ボタンを押下後、時速8キロ以上、座標が駅の中)
        if newLocation.speed * 3.6 >= 8 && recognizeStation == true && measuring == false{
            measuring = true
            if timerSet == false{
                timerSet = true
                startDate = Date()
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateVelocityArray), userInfo: nil, repeats: true)
                startDate = Date().addingTimeInterval(0)
                velocityArray = []
                latitudeArray = []
                longitudeArray = []
                velocityArray.append(0.0)
                latitudeArray.append(newLocation.coordinate.latitude)
                longitudeArray.append(newLocation.coordinate.longitude)
                keisokuLabal.isHidden = true
                depStation = currentStation
            }
            //停車を検知(計測中、時速8キロ以下、タイマー稼働中、座標が駅)
        }else if newLocation.speed * 3.6 < 8 && newLocation.speed * 3.6 < currentVelocity && timerSet == true && recognizeStation == true && measuring == true{
            velocityArray.append(0.0)
            latitudeArray.append(newLocation.coordinate.latitude)
            longitudeArray.append(newLocation.coordinate.longitude)
            measuring = false
            //運転時分を取得、Stringにキャスト
            let timeInterval = Date().timeIntervalSince(startDate)
            let time = Int(timeInterval)
            let m = time / 60 % 60
            let s = time % 60
            let untenJifunString = String(format: "%d分%d秒", m, s)
            startDate = Date()
            timer.invalidate()
            currentVelocity = 0
            var title = String()
            title = "\(retsuban)M \(depStation) →  \(currentStation)間"
            if self.maxVelocity > 15 {
                untenKirokuArray.append(UntenKiroku(retsuban: self.retsuban, title: title, date: Date().timeIntervalSince1970, untenJifun: untenJifunString, maxVelocity: self.maxVelocity, latitudeArray: self.latitudeArray, longitudeArray: self.longitudeArray, velocityArray: self.velocityArray))
            }
            self.maxVelocity = 0.0
            self.velocityArray = []
            self.latitudeArray = []
            self.longitudeArray = []
            timerSet = false
            timer.invalidate()
            measuring = false
            keisokuLabal.isHidden = false
            
            //計測終了の駅であれば
            if stationCount == finalStationCount {
                if untenKirokuArray.count == 0 {
                    alert(title: "エラー", message: "計測終了駅が正しく選択されていません。")
                    self.navigationController?.popViewController(animated: true)
                }
                stopCreatingRunCurve(data: untenKirokuArray)
                self.navigationController?.popViewController(animated: true)
            }
        }else if timerSet == true && newLocation.speed * 3.6 > 4 && recognizeStation == true && measuring == true{
            currentVelocity = newLocation.speed * 3.6
            currentLatitude = newLocation.coordinate.latitude
            currentLongitude = newLocation.coordinate.longitude
            
        }else if timerSet == true && measuring == true && newLocation.speed * 3.6 > 4 && recognizeStation == false{
            currentVelocity = newLocation.speed * 3.6
            currentLatitude = newLocation.coordinate.latitude
            currentLongitude = newLocation.coordinate.longitude
        }
    }
    
    func displayChart(data: [Double]) {
        var dataEntries = [ChartDataEntry]()
        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
        }
        chartDataSet = LineChartDataSet(entries: dataEntries, label: "速度")
        chartDataSet.lineWidth = 2.0
        chartDataSet.mode = .linear
        chartView.data = LineChartData(dataSet: chartDataSet)
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.axisMaximum = 130
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.labelCount = velocityArray.count
        chartView.rightAxis.enabled = false
        chartView.highlightPerTapEnabled = false
        chartView.legend.enabled = true
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.extraTopOffset = 20
        chartView.animate(xAxisDuration: 2)
    }
    
    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    func recognizeStation(lat: Double, log: Double) -> Bool{
        
        if lat >= 31.872453 - 0.0012 && lat <= 31.872453 + 0.0012 && log >= 131.4401 - 0.0012 && log <= 131.4401 + 0.0012{
            
            currentStation = "宮崎空港"
            stationCount = 0
            
            return true
            
        }else if lat >= 31.878974 - 0.0012 && lat <= 31.878974 + 0.0012 && log >= 131.430473 - 0.0012 && log <= 131.430473 + 0.0012{
            
            currentStation = "田吉"
            stationCount = 1
            return true
            
            
        }else if lat >= 31.895107 - 0.0012 && lat <= 31.895107 + 0.0012 && log >= 131.422861 - 0.0012 && log <= 131.422861 + 0.0012{
            
            currentStation = "南宮崎"
            stationCount = 2
            return true
            
            
        }else if lat >= 31.915648 - 0.0012 && lat <= 31.915648 + 0.0012 && log >= 131.431982 - 0.0012 && log <= 131.431982 + 0.0012{
            
            currentStation = "宮崎"
            stationCount = 3
            return true
            
            
        }else if lat >= 31.938186 - 0.0012 && lat <= 31.938186 + 0.0012 && log >= 131.430452 - 0.0012 && log <= 131.430452 + 0.0012{
            
            currentStation = "宮崎神宮"
            stationCount = 4
            return true
            
            
        }else if lat >= 31.960158 - 0.0012 && lat <= 31.960158 + 0.0012 && log >= 131.442864 - 0.0012 && log <= 131.442864 + 0.0012{
            
            currentStation = "蓮ケ池"
            stationCount = 5
            return true
            
            
        }else if lat >= 31.990788 - 0.0012 && lat <= 31.990788 + 0.0012 && log >= 131.457669 - 0.0012 && log <= 131.457669 + 0.0012{
            
            currentStation = "日向住吉"
            stationCount = 6
            return true
            
            
        }else if lat >= 32.022555 - 0.0012 && lat <= 32.022555 + 0.0012 && log >= 131.477382 - 0.0012 && log <= 131.477382 + 0.0012{
            
            currentStation = "佐土原"
            stationCount = 7
            return true
            
            
        }else if lat >= 32.072385 - 0.0012 && lat <= 32.072385 + 0.0012 && log >= 131.501688 - 0.0012 && log <= 131.501688 + 0.0012{
            
            currentStation = "日向新富"
            stationCount = 7
            return true
            
            
        }else if lat >= 32.122717 - 0.0012 && lat <= 32.122717 + 0.0012 && log >= 131.533895 - 0.0012 && log <= 131.533895 + 0.0012{
            
            currentStation = "高鍋"
            stationCount = 9
            return true
            
            
        }else if lat >= 32.19244 - 0.0012 && lat <= 32.19244 + 0.0012 && log >= 131.553272 - 0.0012 && log <= 131.553272 + 0.0012{
            
            currentStation = "川南"
            stationCount = 10
            return true
            
            
        }else if lat >= 32.251259 - 0.0012 && lat <= 32.251259 + 0.0012 && log >= 131.568403 - 0.0012 && log <= 131.568403 + 0.0012{
            
            currentStation = "都農"
            stationCount = 11
            return true
            
            
        }else if lat >= 32.290396 - 0.0012 && lat <= 32.290396 + 0.0012 && log >= 131.58216 - 0.0012 && log <= 131.58216 + 0.0012{
            
            currentStation = "東都農"
            stationCount = 12
            return true
            
            
        }else if lat >= 32.325984 - 0.0012 && lat <= 32.325984 + 0.0012 && log >= 131.602369 - 0.0012 && log <= 131.602369 + 0.0012{
            
            currentStation = "美々津"
            stationCount = 13
            return true
            
            
        }else if lat >= 32.369768 - 0.0012 && lat <= 32.369768 + 0.0012 && log >= 131.627721 - 0.0012 && log <= 131.627721 + 0.0012{
            
            currentStation = "南日向"
            stationCount = 14
            return true
            
            
        }else if lat >= 32.405614 - 0.0012 && lat <= 32.405614 + 0.0012 && log >= 131.627622 - 0.0012 && log <= 131.627622 + 0.0012{
            
            currentStation = "財光寺"
            stationCount = 15
            return true
            
            
        }else if lat >= 32.425796 - 0.0012 && lat <= 32.425796259 + 0.0012 && log >= 131.627978 - 0.0012 && log <= 131.627978 + 0.0012{
            
            currentStation = "日向市"
            stationCount = 16
            return true
            
            
        }else if lat >= 32.477448 - 0.0012 && lat <= 32.477448 + 0.0012 && log >= 131.654055 - 0.0012 && log <= 131.654055 + 0.0012{
            
            currentStation = "門川"
            stationCount = 17
            return true
            
            
        }else if lat >= 32.507813 - 0.0012 && lat <= 32.507813 + 0.0012 && log >= 131.67509 - 0.0012 && log <= 131.67509 + 0.0012{
            
            currentStation = "土々呂"
            stationCount = 18
            return true
            
            
        }else if lat >= 32.528235 - 0.0012 && lat <= 32.528235 + 0.0012 && log >= 131.681385 - 0.0012 && log <= 131.681385 + 0.0012{
            
            currentStation = "旭ヶ丘"
            stationCount = 19
            return true
            
            
        }else if lat >= 32.559776 - 0.0012 && lat <= 32.559776 + 0.0012 && log >= 131.676869 - 0.0012 && log <= 131.676869 + 0.0012{
            
            currentStation = "南延岡"
            stationCount = 20
            return true
            
            
        }else if lat >= 32.590031 - 0.0012 && lat <= 32.590031 + 0.0012 && log >= 131.672471 - 0.0012 && log <=     131.672471 + 0.0012{
            
            currentStation = "延岡"
            stationCount = 21
            return true
            
        }else{
            return false
        }
    }
}



