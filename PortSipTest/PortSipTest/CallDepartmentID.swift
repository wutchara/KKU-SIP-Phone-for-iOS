//
//  CallDepartmentID.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

class CallDepartmentID: CallAPI {
    
    override func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        self.data.appendData(data);
        
    }
    
    override func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            self.parseJSON()
        }
        
    }
    
    override func parseJSON() {
        var jsonResult: NSMutableArray = NSMutableArray()
        var jsonElement: NSDictionary = NSDictionary()
        let departments: NSMutableArray = NSMutableArray()
        //var tableData = [String : String]()
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSMutableArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        
        for(var i = 0; i < jsonResult.count; i++)
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let department = Department()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let id = jsonElement["id"] as? String,
                let name = jsonElement["name"] as? String
            {
                
                //tableData.updateValue(name, forKey: id)
                department.id = id
                department.name = name
                //print("id \(department.id!) : name \(department.name!)")
                
            }
            
            departments.addObject(department)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.itemsDownloaded(departments)
            
        })
    }
}