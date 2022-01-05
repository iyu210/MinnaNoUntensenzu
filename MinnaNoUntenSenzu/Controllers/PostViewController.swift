//
//  PostViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/02.
//

import UIKit
import Charts
import FirebaseFirestore
import Firebase
import FirebaseAuth

class PostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    let stationArray = ["","宮崎空港","田吉","南宮崎","宮崎","宮崎神宮","蓮ケ池","日向住吉","佐土原","日向新富","高鍋","川南","都農","東都農","美々津","南日向","財光寺","日向市","門川","土々呂","旭ヶ丘","南延岡","延岡"]
    
    var finalStationNumber = 0
    
    var alertController: UIAlertController!
    
    let db = Firestore.firestore()
    var documentID = String()
    
    @IBOutlet weak var destinationPickerView: UIPickerView!
    @IBOutlet weak var retsubanTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        destinationPickerView.delegate = self
        destinationPickerView.dataSource = self
        retsubanTextField.delegate = self
        self.navigationItem.title = "運転線図を作成する"
    }
    
    @IBAction func nextVC(_ sender: Any) {
       nextVC()
    }
    
    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        stationArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return stationArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        finalStationNumber = row
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        retsubanTextField.resignFirstResponder()
        nextVC()
        return true
    }
    
    func nextVC(){
        
        if retsubanTextField.text?.isEmpty == true || finalStationNumber == 0{
            alert(title: "エラー", message: "計測を終了する駅か列車番号が正しく入力されていません。")
            retsubanTextField.text = ""
            return
        }
        
        let retsubanText = retsubanTextField.text
        let retsuban = Int(retsubanText!)!
        let retsubanCheck = checkRetsuban(retsubanText: retsubanText)
        if finalStationNumber != 0 && retsubanTextField.text?.isEmpty == false && retsubanCheck == true {
            let measuringVC = storyboard?.instantiateViewController(withIdentifier: "MeasuringVC") as! MeasuringViewController
            measuringVC.retsuban = retsuban
            measuringVC.finalStationCount = finalStationNumber - 1
            self.navigationController?.pushViewController(measuringVC, animated: true)
        }else if finalStationNumber == 0 && retsubanCheck == false && retsubanTextField.text?.isEmpty == true{
            alert(title: "エラー",message: "計測を終了する駅か列車番号が正しく入力されていません。")
        }else if finalStationNumber != 0 && retsubanCheck == false && retsubanTextField.text?.isEmpty == false {
            alert(title: "エラー", message: "対象外の列車番号です。")
        }
        retsubanTextField.text = ""
    }
    
    func checkRetsuban(retsubanText: String!) -> Bool{
        
        if let retsuban = Int(retsubanText){
            if retsuban >= 720 && retsuban <= 757{
                return true
            }else if retsuban >= 6520 && retsuban <= 6537{
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}
