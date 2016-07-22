//
//  FirstViewController.swift
//  PortSipTest
//
//  Created by RnD on 7/12/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    let fileName = "kkuA"
    let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    
    var readString = ""
    
    var fileURL: NSURL = NSURL()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.checkKKUWifi()
        sleep(1)
        
        fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        
        readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        print("######### FirstView ######### \nFile Text: \(readString)")
        
        if(readString == "") {
            let login: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("login") 
            appDelegate.window?.rootViewController = login
            appDelegate.window?.makeKeyAndVisible()
        } else {
            let result = readString.rangeOfString(":",
                                                  options: NSStringCompareOptions.LiteralSearch,
                                                  range: readString.startIndex..<readString.endIndex,
                                                  locale: nil)
            
            appDelegate.login.setUname("\(readString[readString.startIndex..<result!.startIndex])")
            /*
            readDisplayName()
            if(HistoryData.displayName.count == 0 || [HistoryData.displayName] == [""]){
                appDelegate.login.setDisplayName("User : \(readString[readString.startIndex..<result!.startIndex])")
                print("Set Display Name Success : \"User : \(readString[readString.startIndex..<result!.startIndex])\"")
            }else{
                appDelegate.login.setDisplayName("\(HistoryData.displayName)")
                print("Set Display Name Success : \(HistoryData.displayName)")
            }*/
            appDelegate.return_displayName("\(readString[readString.startIndex..<result!.startIndex])")
            sleep(1)
            appDelegate.login.setDisplayName("\(HistoryData.displayName)")
            print("Set Display Name Success : \(HistoryData.displayName)")
            
            appDelegate.login.setPass("\(readString[result!.startIndex.successor()..<readString.endIndex])")
            appDelegate.login.online()
            let tabbar: UITabBarController = storyboard?.instantiateViewControllerWithIdentifier("tabbar") as! UITabBarController
            appDelegate.window?.rootViewController = tabbar
            appDelegate.window?.makeKeyAndVisible()
            
            appDelegate.return_displayName("\(readString[readString.startIndex..<result!.startIndex])")
            print("First Login : display name : \(HistoryData.displayName)")
        }
        
        

        // Do any additional setup after loading the view.
    }
    /*
    func readDisplayName(){
        //read file
        let fileName = "kkuUN"
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        HistoryData.displayName = [readString]
        print("Read File Success : \(readString)")
        print(HistoryData.displayName)
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
