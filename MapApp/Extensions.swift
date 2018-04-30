//
//  Extensions.swift
//  MapApp
//
//  Created by Eldor Makkambaev on 01.05.2018.
//  Copyright © 2018 Eldor Makkambaev. All rights reserved.
//

import UIKit
import MapKit

extension ViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return anotations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: cellId)
        
        cell.backgroundColor = .clear
        let anotation = anotations[indexPath.row]
        let title = anotation.value(forKey: "title") as? String
        let subtitle = anotation.value(forKey: "subtitle") as? String
        let longitude = anotation.value(forKey: "longitude") as? Double
        let latitude = anotation.value(forKey: "latitude") as? Double
        if let nonTitle = title, let nonSubtitle = subtitle, let nonLong = longitude, let nonLat = latitude{
            let coordinate = CLLocationCoordinate2D.init(latitude: nonLat, longitude: nonLong)
            let anotation = Anotation.init(title: nonTitle, locationName: nonSubtitle, coordinate: coordinate)
            mapView.addAnnotation(anotation)
        }
        if let title = title, let subtitle = subtitle{
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subtitle
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        viewOfTableView.isHidden = true
        viewOfMap.isHidden = false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let anotation = anotations[indexPath.row]
            deleteAnotation(anotation: anotation)
            getAnotations()
            mapView.removeAnnotations(mapView.annotations)
            tableView.reloadData()
            if anotations.count == 0{
                heightLabelAnchor?.constant = 200
            }
        }
    }
    
}










// Setupping views
extension ViewController{
    func setupMapKit(){
        mapView.delegate = self
        view.addSubview(viewOfMap)
        viewOfMap.addSubview(mapView)
        //mapView.anchorFullSize(to: viewOfMap)
        
        let blur = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurView = UIVisualEffectView(effect: blur)
        viewOfMap.addSubview(blurView)
        
        blurView.anchor(top: nil, leading: viewOfMap.leadingAnchor,
                        bottom: viewOfMap.bottomAnchor, trailing: viewOfMap.trailingAnchor)
        blurView.heightAnchor.constraint(equalTo: viewOfMap.heightAnchor, multiplier: 0.15).isActive = true
        
        viewOfMap.addSubview(typeSegmentedControl)
        viewOfMap.addSubview(ArrowRight)
        viewOfMap.addSubview(ArrowLeft)
        
        typeSegmentedControl.centerXAnchor.constraint(equalTo: blurView.centerXAnchor).isActive = true
        typeSegmentedControl.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        typeSegmentedControl.widthAnchor.constraint(equalToConstant: 200).isActive = true
        typeSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        ArrowLeft.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        ArrowLeft.trailingAnchor.constraint(equalTo: typeSegmentedControl.leadingAnchor, constant: -16).isActive = true
        ArrowLeft.widthAnchor.constraint(equalToConstant: 25).isActive = true
        ArrowLeft.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        ArrowRight.centerYAnchor.constraint(equalTo: blurView.centerYAnchor).isActive = true
        ArrowRight.leadingAnchor.constraint(equalTo: typeSegmentedControl.trailingAnchor, constant: 16).isActive = true
        ArrowRight.widthAnchor.constraint(equalToConstant: 25).isActive = true
        ArrowRight.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
    }
    
    func setupTableView(){
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        //tableView.backgroundView = blurView
        
        
        viewOfTableView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(viewOfTableView)
        viewOfTableView.addSubview(blurView)
        viewOfTableView.addSubview(tableView)
        viewOfTableView.addSubview(labelNoPlaces)
        
        blurView.anchorFullSize(to: viewOfTableView)
        
        labelNoPlaces.topAnchor.constraint(equalTo: viewOfTableView.topAnchor).isActive = true
        labelNoPlaces.leadingAnchor.constraint(equalTo: viewOfTableView.leadingAnchor).isActive = true
        labelNoPlaces.trailingAnchor.constraint(equalTo: viewOfTableView.trailingAnchor).isActive = true
        heightLabelAnchor = labelNoPlaces.heightAnchor.constraint(equalToConstant: 200)
        heightLabelAnchor?.isActive = true
        
        tableView.anchor(top: labelNoPlaces.bottomAnchor, leading: viewOfTableView.leadingAnchor,
                         bottom: viewOfTableView.bottomAnchor, trailing: viewOfTableView.trailingAnchor)
        
    }
}





extension UIView{
    func anchorFullSize(to view: UIView){
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero){
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top{
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading{
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom{
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing{
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        if size.width != 0{
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0{
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}
