//
//  ViewController.swift
//  MapApp
//
//  Created by Eldor Makkambaev on 01.05.2018.
//  Copyright © 2018 Eldor Makkambaev. All rights reserved.
//

import UIKit
import MapKit
import CoreData




class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    var anotations = [NSManagedObject]()
    var tableIsHidden = true
    let cellId = "cellId"
    var heightLabelAnchor: NSLayoutConstraint?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(named: "list"), style: .plain, target: self, action: #selector(handleList))
        view.backgroundColor = .white
        setupMapKit()
        setupTableView()
        mapView.showsUserLocation = true
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        getAnotations()
        tableView.reloadData()
        if anotations.count == 0{
            heightLabelAnchor?.constant = 200
        }
        else {
            heightLabelAnchor?.constant = 0
        }
        viewOfTableView.isHidden = true
        viewOfTableView.alpha = 0
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let title = view.annotation?.title{
            navigationItem.title = title
        }
    }
    
    @objc func handleList(){
        if tableIsHidden{
            viewOfTableView.isHidden = false
            viewOfTableView.alpha = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.viewOfTableView.alpha = 1
            }, completion: { (_) in
                
            })
            
            
            //viewOfMap.isHidden = true
            tableIsHidden = false
        }
        else {
            
            viewOfTableView.alpha = 1
            UIView.animate(withDuration: 0.4, animations: {
                self.viewOfTableView.alpha = 0
            }, completion: { (_) in
                self.viewOfTableView.isHidden = true
            })
            
            //viewOfMap.isHidden = false
            tableIsHidden = true
        }
    }
    
    
    // Views
    lazy var viewOfMap: UIView = {
        let myView = UIView()
        myView.frame = view.frame
        return myView
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.frame = view.frame
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap))
        mapView.addGestureRecognizer(tap)
        mapView.isUserInteractionEnabled = true
        return mapView
    }()
    @objc func handleMapTap(sender: UILongPressGestureRecognizer){
        let touchlocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchlocation, toCoordinateFrom: mapView)
        print(locationCoordinate)
        
        let alertController = UIAlertController(title: "Add New Place", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Title"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            let secondTextField = alertController.textFields![1] as UITextField
            if let title = firstTextField.text, let subtitle = secondTextField.text{
                if !title.isEmpty && !subtitle.isEmpty{
                    self.navigationItem.title = title
                    let coordinate = CLLocationCoordinate2D.init(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                    let anotation = Anotation.init(title: title, locationName: subtitle, coordinate: coordinate)
                    self.mapView.addAnnotation(anotation)
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    self.mapView.setRegion(MKCoordinateRegion.init(center: coordinate, span: span), animated: true)
                    self.saveAnotation(title: title, subtitle: subtitle, latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                    self.getAnotations()
                    self.tableView.reloadData()
                    self.heightLabelAnchor?.constant = 0
                }
            }
            
        })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Subtitle"
        }
        
        alertController.addAction(saveAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    lazy var typeSegmentedControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.tintColor = .black
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(handleTypeChange), for: .valueChanged)
        return segmentControl
    }()
    
    @objc func handleTypeChange(){
        switch typeSegmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
            break
        case 1:
            mapView.mapType = .satellite
            break
        case 2:
            mapView.mapType = .hybrid
            break
        default:
            print("Bla bla bla bla")
        }
        
    }
    
    lazy var ArrowRight: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "right_arrow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //let tap = UIGestureRecognizer.init(target: self, action: #selector(handleRight))
        button.addTarget(self, action: #selector(handleRight), for: .touchUpInside)
        return button
    }()
    @objc func handleRight(){
        print("right")
        if let title = navigationItem.title{
            if let currentIndexPath = getCurrentIndex(title: title){
                let indexPath: IndexPath
                if currentIndexPath.row == anotations.count-1{
                    indexPath = IndexPath.init(row: 0, section: 0)
                } else {
                    indexPath = IndexPath.init(row: currentIndexPath.row + 1, section: 0)
                }
                let anotation = anotations[indexPath.row]
                let title = anotation.value(forKey: "title") as? String
                //let subtitle = anotation.value(forKey: "subtitle") as? String
                let longitude = anotation.value(forKey: "longitude") as? Double
                let latitude = anotation.value(forKey: "latitude") as? Double
                if let latitude = latitude, let longitude = longitude, let title = title{
                    navigationItem.title = title
                    let coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    self.mapView.setRegion(MKCoordinateRegion.init(center: coordinate, span: span), animated: true)
                }
            }
        }
    }
    lazy var ArrowLeft: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: "left_arrow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //let tap = UIGestureRecognizer.init(target: self, action: #selector(handleLeft))
        button.addTarget(self, action: #selector(handleLeft), for: .touchUpInside)
        return button
    }()
    @objc func handleLeft(){
        print("left")
        if let title = navigationItem.title{
            if let currentIndexPath = getCurrentIndex(title: title){
                let indexPath: IndexPath
                if currentIndexPath.row == 0{
                    indexPath = IndexPath.init(row: anotations.count-1, section: 0)
                } else {
                    indexPath = IndexPath.init(row: currentIndexPath.row - 1, section: 0)
                }
                let anotation = anotations[indexPath.row]
                let title = anotation.value(forKey: "title") as? String
                //let subtitle = anotation.value(forKey: "subtitle") as? String
                let longitude = anotation.value(forKey: "longitude") as? Double
                let latitude = anotation.value(forKey: "latitude") as? Double
                if let latitude = latitude, let longitude = longitude, let title = title{
                    navigationItem.title = title
                    let coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    self.mapView.setRegion(MKCoordinateRegion.init(center: coordinate, span: span), animated: true)
                }
            }
        }
    }
    
    var selectedAnnotation: Anotation?
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? Anotation
    }
    
    
    lazy var viewOfTableView: UIView = {
        let myView = UIView()
        myView.frame = view.frame
        return myView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = view.frame
        let longPressRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongClickUpdate))
        tableView.addGestureRecognizer(longPressRecognizer)
        return tableView
    }()
    
    @objc func handleLongClickUpdate(longPressGestureRecognizer: UILongPressGestureRecognizer){
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let title = anotations[indexPath.row].value(forKey: "title") as? String
                let subtitle = anotations[indexPath.row].value(forKey: "subtitle") as? String
                if let title = title, let subtitle = subtitle{
                    let alertController = UIAlertController(title: "Updating \(title)", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addTextField { (textField : UITextField!) -> Void in
                        textField.text = title
                        
                    }
                    let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
                        let firstTextField = alertController.textFields![0] as UITextField
                        let secondTextField = alertController.textFields![1] as UITextField
                        if let title = firstTextField.text, let subtitle = secondTextField.text{
                            self.update(title: title, subtitle: subtitle, indexPath: indexPath)
                            self.getAnotations()
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            
                            self.tableView.reloadData()
                        }
                    })
                    alertController.addTextField { (textField : UITextField!) -> Void in
                        textField.text = subtitle
                    }
                    
                    alertController.addAction(saveAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    lazy var labelNoPlaces: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No places"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
}


extension ViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let anotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView{
            anotation.animatesWhenAdded = true
            anotation.titleVisibility = .adaptive
            
            return anotation
        }
        return nil
    }
}


