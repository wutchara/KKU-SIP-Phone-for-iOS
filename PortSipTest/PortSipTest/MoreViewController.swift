//
//  MoreViewController.swift
//  PortSipTest
//
//  Created by RnD on 7/12/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameLab: UILabel!
    @IBOutlet weak var UserPassLab: UILabel!

    @IBAction func deleteProfileBtn(sender: AnyObject) {
        
        indicator.hidden = false
        indicator.startAnimating()
        
        appDelegate.checkNetwork = false
        showAlert("Do you want to Delete Profile ?", message: "If you want to \"Delete Profile\" touch \"Yes\". If you delete profile success plase touch \"Re Login\" for new account", btnL: "No", btnR: "Yes")
    }
    
    func showAlert(title: String, message: String, btnL: String, btnR: String){
        let createAccountErrorAlert: UIAlertView = UIAlertView()
        
        createAccountErrorAlert.delegate = self
        
        createAccountErrorAlert.title = title
        createAccountErrorAlert.message = message
        createAccountErrorAlert.addButtonWithTitle(btnL)
        createAccountErrorAlert.addButtonWithTitle(btnR)
        
        createAccountErrorAlert.show()
    }
    
    //check alert
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 1:
            NSLog("Yes");
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //write file
            let fileName = "kkuA"
            let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
            // Save data to file
            let writeString = ""
            do {
                // Write to the file
                try writeString.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL
                
                userNameLab.text = "-- EMPTY --"
                UserPassLab.text = "-- EMPTY --"
                
                appDelegate.login.offline()
                
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
            let fileName2 = "kkuHIN"
            let fileURL2 = DocumentDirURL.URLByAppendingPathComponent(fileName2).URLByAppendingPathExtension("txt")
            // Save data to file
            let writeString2 = ""
            do {
                // Write to the file
                try writeString2.writeToURL(fileURL2, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL2
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL2), Error: " + error.localizedDescription)
            }
            
            let fileName3 = "kkuHI"
            let fileURL3 = DocumentDirURL.URLByAppendingPathComponent(fileName3).URLByAppendingPathExtension("txt")
            // Save data to file
            let writeString3 = ""
            do {
                // Write to the file
                try writeString3.writeToURL(fileURL3, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL3
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL3), Error: " + error.localizedDescription)
            }
            
            let fileName4 = "kkuCallstatus"
            let fileURL4 = DocumentDirURL.URLByAppendingPathComponent(fileName4).URLByAppendingPathExtension("txt")
            // Save data to file
            let writeString4 = ""
            do {
                // Write to the file
                try writeString4.writeToURL(fileURL4, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL4
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL4), Error: " + error.localizedDescription)
            }
            
            let fileName5 = "kkuCalltime"
            let fileURL5 = DocumentDirURL.URLByAppendingPathComponent(fileName5).URLByAppendingPathExtension("txt")
            // Save data to file
            let writeString5 = ""
            do {
                // Write to the file
                try writeString5.writeToURL(fileURL5, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL5
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL5), Error: " + error.localizedDescription)
            }

            break;
        case 0:
            NSLog("No");
            break;
        default:
            NSLog("Default");
            break;
            //Some code here..
        }
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        indicator.hidden = true
        
        
        //show User name
        let fileName = "kkuA"
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        print("\nFile Text: \(readString)")
        
        // Search for one string in another.
        let result = readString.rangeOfString(":",
                                              options: NSStringCompareOptions.LiteralSearch,
                                              range: readString.startIndex..<readString.endIndex,
                                              locale: nil)
        
        userNameLab.text = "\(readString[readString.startIndex..<result!.startIndex])"
        UserPassLab.text = "\(readString[result!.startIndex.successor()..<readString.endIndex.predecessor().predecessor()])xx"
    }

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
