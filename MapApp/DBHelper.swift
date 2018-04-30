//
//  DBHelper.swift
//  MapApp
//
//  Created by Eldor Makkambaev on 01.05.2018.
//  Copyright © 2018 Eldor Makkambaev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ViewController {
    func getAnotations(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let requestForList = NSFetchRequest<NSFetchRequestResult>(entityName: "Anotations")
        requestForList.returnsObjectsAsFaults = false
        do {
            anotations = try context.fetch(requestForList) as! [NSManagedObject]
        }
        catch {
            print("some errors")
        }
    }
    
    func saveAnotation(title: String, subtitle: String, latitude: Double, longitude: Double) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newAnotation = NSEntityDescription.insertNewObject(forEntityName: "Anotations", into: context)
        
        newAnotation.setValue(title, forKey: "title")
        newAnotation.setValue(subtitle, forKey: "subtitle")
        newAnotation.setValue(latitude, forKey: "latitude")
        newAnotation.setValue(longitude, forKey: "longitude")
        do {
            try context.save()
            anotations.append(newAnotation)
            print("Saved website")
        } catch {
            print("wasn't  saved")
        }
    }
    func deleteAnotation(anotation: NSManagedObject){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(anotation)
        do {
            try context.save()
        } catch {
            print("some error")
        }
    }
    func update(title: String, subtitle: String, indexPath: IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let anotation = anotations[indexPath.row]
        anotation.setValue(title, forKey: "title")
        anotation.setValue(subtitle, forKey: "subtitle")
        do {
            try context.save()
        } catch {
            print("some error")
        }
    }
    func getCurrentIndex(title: String) -> IndexPath?{
        var count = 0
        for anotation in anotations{
            let title = anotation.value(forKey: "title") as? String
            if let titleAnotation = title{
                if let title = navigationItem.title{
                    if title == titleAnotation{
                        return IndexPath.init(row: count, section: 0)
                    }
                    count += 1
                }
            }
        }
        return nil
    }
}


