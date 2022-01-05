//
//  RunCurveViewController.swift
//  MinnaNoUntenSenzu
//
//  Created by 岩渕優児 on 2021/10/02.
//

import UIKit
import MapKit
import Charts

class RunCurveViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var mapView: MKMapView!
    var slider: UISlider!
    var chartView: LineChartView!
    
    var chartDataSet: LineChartDataSet!
    var untenKiroku: UntenKiroku!
    var locationManager = CLLocationManager()
    var mkCoordinate = MKCoordinateSpan()
    var center = CLLocationCoordinate2D()
    var pinView: MKPinAnnotationView!
    var annotation: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        locationManager.delegate = self
        let navbarHeight = navigationBarHeight(callFrom: self)
        let tabbarHeight = self.tabBarController?.tabBar.frame.height
        let viewHeight = view.frame.size.height - navbarHeight! - tabbarHeight!
        mapView = MKMapView(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: viewHeight * 0.4))
        view.addSubview(mapView)
        chartView = LineChartView(frame: CGRect(x: 0, y: 100 + mapView.frame.height + 10 , width: view.frame.width - 20, height: viewHeight * 0.4))
        view.addSubview(chartView)
        slider = UISlider(frame: CGRect(x: 15, y: 100 + mapView.frame.size.height + chartView.frame.size.height + 20, width: view.frame.size.width - 15, height: viewHeight * 0.1))
        view.addSubview(slider)
        center = CLLocationCoordinate2D(latitude: untenKiroku!.latitudeArray[0], longitude: untenKiroku!.longitudeArray[0])
        displayChart(data: untenKiroku!.velocityArray)
        slider.minimumValue = 0.0
        slider.maximumValue = Float(untenKiroku!.velocityArray.count - 1)
        slider.addTarget(self, action: #selector(sliderDidChangeValue(_:)), for: .valueChanged)
        view.addSubview(slider)
        let center = CLLocationCoordinate2DMake(untenKiroku!.latitudeArray[0], untenKiroku!.longitudeArray[0])
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(self.untenKiroku!.latitudeArray[0], self.untenKiroku!.longitudeArray[0])
        annotation.title = String(untenKiroku!.velocityArray[0]) + "km/h"
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated:true)
        mapView.delegate = self
        mapView.mapType = .hybrid
        self.navigationItem.title = untenKiroku.title
    }
    
    @objc func sliderDidChangeValue(_ sender: UISlider) {
        let value = Int(sender.value)
        
        if annotation == nil {
           
            annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2DMake(self.untenKiroku.latitudeArray[value], self.untenKiroku.longitudeArray[value])
            annotation.title = String(untenKiroku.velocityArray[value]) + "km/h"
            mapView.addAnnotation(annotation)
        } else {
            let center = CLLocationCoordinate2DMake(untenKiroku.latitudeArray[value], untenKiroku.longitudeArray[value])
            let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated:true)
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.annotation.coordinate = CLLocationCoordinate2DMake(self.untenKiroku.latitudeArray[Int(value)], self.untenKiroku.longitudeArray[Int(value)])
                self.annotation.title = String(self.untenKiroku.velocityArray[value]) + "km/h"
            }, completion:nil)
        }
    }
    
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "testPin")
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        return pinView
    }
    
    
    func displayChart(data: [Double]) {
        
        var dataEntries = [ChartDataEntry]()
        
        for (xValue, yValue) in data.enumerated() {
            let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
            dataEntries.append(dataEntry)
        }
   
        chartDataSet = LineChartDataSet(entries: dataEntries, label: untenKiroku.title)
        
        chartDataSet.lineWidth = 5.0
        chartDataSet.mode = .cubicBezier
        chartView.data = LineChartData(dataSet: chartDataSet)
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.enabled = false
   
        chartView.leftAxis.axisMaximum = 130
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.labelCount = untenKiroku.velocityArray.count
        chartView.rightAxis.enabled = false

        chartView.highlightPerTapEnabled = false
        chartView.legend.enabled = false
        chartView.pinchZoomEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.extraTopOffset = 20
        
        chartView.animate(xAxisDuration: 1)
        
    }
    
    func navigationBarHeight(callFrom: UIViewController) -> CGFloat? {
        return callFrom.navigationController?.navigationBar.frame.size.height
    }
}
