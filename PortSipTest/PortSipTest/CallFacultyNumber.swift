//
//  CallFacultyNumber.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

class CallFacultyNumber: CallAPI {
    
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
        //var jsonResult: NSMutableArray = NSMutableArray()
        var jsonResult: NSArray = NSArray()
        var jsonElement: NSDictionary = NSDictionary()
        let facultys: NSMutableArray = NSMutableArray()
        do{
            jsonResult = try NSJSONSerialization.JSONObjectWithData(self.data, options:NSJSONReadingOptions.AllowFragments) as! NSArray
            
        } catch let error as NSError {
            print(error)
            
        }
        
        
        for i in 0..<jsonResult.count
        {
            
            jsonElement = jsonResult[i] as! NSDictionary
            
            let faculty = Faculty()
            
            //the following insures none of the JsonElement values are nil through optional binding
            if let num = jsonElement["kku_tel"] as? String,
                let division = jsonElement["division"] as? String
            {
                
                faculty.kku_tel = num
                faculty.division = division

            }
            
            facultys.addObject(faculty)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.delegate.itemsDownloaded(facultys)
            
        })
    }
}