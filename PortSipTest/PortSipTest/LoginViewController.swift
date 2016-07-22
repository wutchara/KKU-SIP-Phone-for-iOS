//
//  LoginViewController.swift
//  PortSipTest
//
//  Created by RnD on 6/22/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginBut: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let alert = UIAlertController(title: "Warning !!!", message: "Invalide Username or Password", preferredStyle: UIAlertControllerStyle.Alert)
    
    var readString = "" // Used to store the file contents

    //save file
    let fileName = "kkuA"
    let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    var fileURL: NSURL = NSURL()
    
    /*
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }*/
    
    @IBAction func loginBut(sender: AnyObject) {
        
        if username.text == "" || password.text == "" || username.text?.characters.count != 5 || password.text?.characters.count != 5 {
            //indicator.stopAnimating()
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            //indicator.hidden = false
            //indicator.startAnimating()
            appDelegate.checkKKUWifi()
            sleep(1)
            self.username.resignFirstResponder()
            self.password.resignFirstResponder()
            
            //indicator.stopAnimating()
            print(username.text)
            
            print(password.text)
            appDelegate.login.setUname(username.text!)
            appDelegate.login.setPass(password.text!)
            
            /*
            readDisplayName()
            if(HistoryData.displayName.count == 0 || [HistoryData.displayName] == [""]){
                appDelegate.login.setDisplayName("User : \(username.text!)")
                print("LOGIN : set display name success : \"User : \(username.text!)\"")
            }else{
                appDelegate.login.setDisplayName("\(HistoryData.displayName)")
                print("LOGIN : set display name success : \(HistoryData.displayName)")
            }
            */
            appDelegate.return_displayName("\(username.text!)")
            sleep(1)
            appDelegate.login.setDisplayName("\(HistoryData.displayName)")
            print("Set Display Name Success : \(HistoryData.displayName)")
            
            appDelegate.login.online()
            
            // Save data to file
            let data_user = username.text!
            let data_pass = password.text!
            
            let writeString = "\(data_user):\(data_pass)"
            do {
                // Write to the file
                try writeString.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
                appDelegate.pathSaveFile = fileURL
            } catch let error as NSError {
                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
            }
            
            readString = "" // Used to store the file contents
            do {
                // Read the file contents
                readString = try String(contentsOfURL: fileURL)
            } catch let error as NSError {
                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
            }
            print("\nFile Text: \(readString)")
        }
        
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
    
    override func viewDidLoad() {
        
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        super.viewDidLoad()
        indicator.hidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        //save file
        fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        print("FilePath: \(fileURL.path)")
        
        /*
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
 */
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /* circular button
    func configureButton()
    {
        loginBut.layer.cornerRadius = 0.5 * loginBut.bounds.size.width
        loginBut.layer.borderColor = UIColor(red:1, green:1, blue:1, alpha:1).CGColor as CGColorRef
        loginBut.layer.borderWidth = 2.0
        loginBut.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        configureButton()
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
