//
//  HistoryData.swift
//  PortSipTest
//
//  Created by RnD on 6/22/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

struct HistoryData {
    static var data = [String]()
    static var num = [String]()

    static var call_action = [String]()
    
    static var time = [String]()
    //static var displayName = [String]()
    
    static var displayName = String()
    
    // date display
    let date = NSDate()
    let calendar = NSCalendar.currentCalendar()
    
    func updateTime() -> String {
        let hh = calendar.components(.Hour, fromDate: date)
        let hour = hh.hour
        
        let mm = calendar.components(.Minute, fromDate: date)
        let minute = mm.minute
        
        let DD = calendar.components(.Day, fromDate: date)
        let day = DD.day
        
        let MM = calendar.components(.Month, fromDate: date)
        let month = MM.month
        
        let YY = calendar.components(.Year, fromDate: date)
        let year = YY.year
        
        var hourCheck = ""
        var minCheck = ""
        
        if(hour<10) {
            hourCheck = "0\(hour)"
        } else {
            hourCheck = "\(hour)"
        }
        
        if(minute<10) {
            minCheck = "0\(minute)"
        } else {
            minCheck = "\(minute)"
        }
        
        return "\(day)-\(month)-\(year) \(hourCheck):\(minCheck) น."
    }
    
    
    func readHistoryFile(){
        
        let fileName = "kkuHI"
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        
        let fileName_num = "kkuHIN"
        let DocumentDirURL_num = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL_num = DocumentDirURL_num.URLByAppendingPathComponent(fileName_num).URLByAppendingPathExtension("txt")
        var readString_num = "" // Used to store the file contents
        do {
            // Read the file contents
            readString_num = try String(contentsOfURL: fileURL_num)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileName_num), Error: " + error.localizedDescription)
        }
        
        
        let fileNameStatus = "kkuCallstatus"
        let DocumentDirURLstatus = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURLstatus = DocumentDirURLstatus.URLByAppendingPathComponent(fileNameStatus).URLByAppendingPathExtension("txt")
        var readStatus = "" // Used to store the file contents
        do {
            // Read the file contents
            readStatus = try String(contentsOfURL: fileURLstatus)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileNameStatus), Error: " + error.localizedDescription)
            
        }
        
        let fileNameTime = "kkuCalltime"
        let DocumentDirURLtime = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURLtime = DocumentDirURLtime.URLByAppendingPathComponent(fileNameTime).URLByAppendingPathExtension("txt")
        var readTime = "" // Used to store the file contents
        do {
            // Read the file contents
            readTime = try String(contentsOfURL: fileURLtime)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileNameTime), Error: " + error.localizedDescription)
            
        }


        
        readString = "\(readString),"
        readString_num = "\(readString_num),"
        readStatus = "\(readStatus),"
        readTime = "\(readTime),"
        
        //=========================================
        var temp_readString : [String] = []
        var temp_string: String = ""
        var readString_count = readString.characters.startIndex
        //var readString_count_int: Int = 0
        
        print(" after : \(readString_count), \(readString.characters.count)")
        for i in 0..<readString.characters.count{
            if(readString[readString.startIndex.advancedBy(i)] == ","){
                readString_count = readString_count.successor()
                //readString_count_int = readString_count_int + 1
                print("found")
                
                temp_readString.append(temp_string)
                temp_string = ""
            }else{
                temp_string = "\(temp_string)\(readString[readString.startIndex.advancedBy(i)])"
            }
            print(readString[readString.startIndex.advancedBy(i)])
        }
        if("\(readString_count)" == "0"){
            temp_readString.append("\(readString)")
        }
        print(" before : \(readString_count), \(readString.characters.count)")
        
        //=====================================================================
        var temp_readString_num : [String] = []
        var temp_string_num: String = ""
        var readString_count_num = readString_num.characters.startIndex
        //var readString_count_int: Int = 0
        
        print(" after : \(readString_count_num), \(readString_num.characters.count)")
        for i in 0..<readString_num.characters.count{
            if(readString_num[readString_num.startIndex.advancedBy(i)] == ","){
                readString_count_num = readString_count_num.successor()
                //readString_count_int = readString_count_int + 1
                print("found")
                
                temp_readString_num.append(temp_string_num)
                temp_string_num = ""
            }else{
                temp_string_num = "\(temp_string_num)\(readString_num[readString_num.startIndex.advancedBy(i)])"
            }
            print(readString_num[readString_num.startIndex.advancedBy(i)])
        }
        print(" before : \(readString_count_num), \(readString_num.characters.count)")
        if("\(readString_count_num)" == "0"){
            temp_readString_num.append("\(readString_num)")
        }
        //==============================================
        
        var temp_ReadStatus : [String] = []
        var temp_status: String = ""
        var readStatus_count = readStatus.characters.startIndex
        //var readString_count_int: Int = 0
        
        print(" after : \(readStatus_count), \(readString.characters.count)")
        for i in 0..<readStatus.characters.count{
            if(readStatus[readStatus.startIndex.advancedBy(i)] == ","){
                readStatus_count = readStatus_count.successor()
                //readString_count_int = readString_count_int + 1
                print("found")
                
                temp_ReadStatus.append(temp_status)
                temp_status = ""
            }else{
                temp_status = "\(temp_status)\(readStatus[readStatus.startIndex.advancedBy(i)])"
            }
            print(readStatus[readStatus.startIndex.advancedBy(i)])
        }
        if("\(readStatus_count)" == "0"){
            temp_ReadStatus.append("\(readStatus)")
        }
        print(" before : \(readStatus_count), \(readStatus.characters.count)")
        
        //=====================================================================
        
        var temp_ReadTime : [String] = []
        var temp_time: String = ""
        var readTime_count = readTime.characters.startIndex
        //var readString_count_int: Int = 0
        
        print(" after : \(readTime_count), \(readString.characters.count)")
        for i in 0..<readTime.characters.count{
            if(readTime[readTime.startIndex.advancedBy(i)] == ","){
                readTime_count = readTime_count.successor()
                //readString_count_int = readString_count_int + 1
                print("found")
                
                temp_ReadTime.append(temp_time)
                temp_time = ""
            }else{
                temp_time = "\(temp_time)\(readTime[readTime.startIndex.advancedBy(i)])"
            }
            print(readTime[readTime.startIndex.advancedBy(i)])
        }
        if("\(readTime_count)" == "0"){
            temp_ReadTime.append("\(readTime)")
        }
        print(" before : \(readTime_count), \(readTime.characters.count)")
        
        //=====================================================================
        
        HistoryData.data = temp_readString
        HistoryData.num = temp_readString_num
        HistoryData.call_action = temp_ReadStatus
        HistoryData.time = temp_ReadTime
        print("Name File :\(readString)////// Phone File : \(readString_num) Histroy")
        print(HistoryData.data)
        print(HistoryData.num)
        
    }
    
    func saveHistory(var name: [String], var phoneNumber: [String], var status: [String], var time: [String]){
        //for save name
        // Save data to file
        if(name.isEmpty) {
            name = [""]
            phoneNumber = [""]
            status = ["unknown"]
            time = [""]
        }
        
        let fileName = "kkuHI"
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        
        let user_name = name
        //let user_type = "I"
        
        //read
        /*var readString = "" // Used to store the file contents
         do {
         // Read the file contents
         readString = try String(contentsOfURL: fileURL)
         } catch let error as NSError {
         print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
         }*/
        
        var writeString = ""
        //write
        //print(user_name[0])
        for i in 0..<user_name.count {
            writeString = "\(writeString),\(user_name[i])"
        }
        
        writeString.removeAtIndex(writeString.startIndex)
        
        do {
            // Write to the file
            try writeString.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
        //end save name
        
        
        //######################################################################################
        //for save phone number
        // Save data to file
        let fileName_num = "kkuHIN"
        let DocumentDirURL_num = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL_num = DocumentDirURL_num.URLByAppendingPathComponent(fileName_num).URLByAppendingPathExtension("txt")
        
        let user_phone = phoneNumber
        
        /*//read
         var readString_num = "" // Used to store the file contents
         do {
         // Read the file contents
         readString_num = try String(contentsOfURL: fileURL)
         } catch let error as NSError {
         print("Failed reading from URL: \(fileName_num), Error: " + error.localizedDescription)
         }*/
        
        //write
        var writeString_num = ""
        //write
        //print(user_name[0])
        for i in 0..<user_phone.count {
            writeString_num = "\(writeString_num),\(user_phone[i])"
        }
        
        writeString_num.removeAtIndex(writeString_num.startIndex)
        
        do {
            // Write to the file
            try writeString_num.writeToURL(fileURL_num, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileName_num), Error: " + error.localizedDescription)
        }
        //end save phone number
        
        //######################################################################################
        //for save phone status
        // Save data to file
        let fileName_status = "kkuCallstatus"
        let DocumentDirURLstatus = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURLstatus = DocumentDirURLstatus.URLByAppendingPathComponent(fileName_status).URLByAppendingPathExtension("txt")
        
        let user_status = status
        
        /*//read
         var readString_num = "" // Used to store the file contents
         do {
         // Read the file contents
         readString_num = try String(contentsOfURL: fileURL)
         } catch let error as NSError {
         print("Failed reading from URL: \(fileName_num), Error: " + error.localizedDescription)
         }*/
        
        //write
        var writeString_status = ""
        //write
        //print(user_name[0])
        for i in 0..<user_status.count {
            writeString_status = "\(writeString_status),\(user_status[i])"
        }
        
        writeString_status.removeAtIndex(writeString_status.startIndex)
        
        do {
            // Write to the file
            try writeString_status.writeToURL(fileURLstatus, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileName_status), Error: " + error.localizedDescription)
        }
        //end save phone status
        
        //######################################################################################
        
        //for save phone time
        // Save data to file
        let fileName_time = "kkuCalltime"
        let DocumentDirURLtime = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURLtime = DocumentDirURLtime.URLByAppendingPathComponent(fileName_time).URLByAppendingPathExtension("txt")
        
        
        let user_time = time
        
        /*//read
         var readString_num = "" // Used to store the file contents
         do {
         // Read the file contents
         readString_num = try String(contentsOfURL: fileURL)
         } catch let error as NSError {
         print("Failed reading from URL: \(fileName_num), Error: " + error.localizedDescription)
         }*/
        
        //write
        var writeString_time = ""
        //write
        //print(user_name[0])
        for i in 0..<user_time.count {
            writeString_time = "\(writeString_time),\(user_time[i])"
        }
        
        writeString_time.removeAtIndex(writeString_time.startIndex)
        
        do {
            // Write to the file
            try writeString_time.writeToURL(fileURLtime, atomically: true, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Failed writing to URL: \(fileName_time), Error: " + error.localizedDescription)
        }
        //end save phone time
        
        //######################################################################################
        
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        
        var readString_num = "" // Used to store the file contents
        do {
            // Read the file contents
            readString_num = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileName_num), Error: " + error.localizedDescription)
        }
        
        
        print("Name File :\(readString), Phone File : \(readString_num)")
            
        }
}