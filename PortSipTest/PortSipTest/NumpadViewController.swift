
//  NumpadViewController.swift
//  PortSipTest
//
//  Created by RnD on 6/22/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class NumpadViewController: UIViewController , UITextFieldDelegate, KeyboardDelegate{
    
    //call variable
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let showStartPhoneNumber: String = "SIP KKU phone number"
    var checkFirstClick: Bool = true
    var showPhoneNumber: String = ""
    var activeTextField = UITextField()

    var textNum = ""
    
    var callOut: UIViewController!
    
    @IBOutlet weak var test: UILabel!
    
    @IBOutlet weak var keyboardView: Keyboard!
    
    @IBOutlet weak var showUname: UILabel!
    
    /*
    @IBAction func delBtn(sender: AnyObject) {
    actionInputPhoneNumber("delete", data: "")
    }
    @IBAction func oneBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "1")
    }
    @IBAction func twoBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "2")
    }
    @IBAction func threeBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "3")
    }
    @IBAction func fourBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "4")
    }
    @IBAction func fiveBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "5")
    }
    @IBAction func sixBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "6")
    }
    @IBAction func savenBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "7")
    }
    @IBAction func eightBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "8")
    }
    @IBAction func nineBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "9")
    }
    @IBAction func starBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "*")
    }
    @IBAction func zeroBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "0")
    }
    @IBAction func shapeBtn(sender: AnyObject) {
    actionInputPhoneNumber("add", data: "#")
    }
    */
    
    /*func actionInputPhoneNumber(action: String, data: String){
    if(action == "add"){
    clearText()
    showPhoneNumber = inputPhoneNumber.text!
    inputPhoneNumber.text = "\(showPhoneNumber)\(data)"
    }else if(action == "delete"){
    clearText()
    showPhoneNumber = inputPhoneNumber.text!
    if showPhoneNumber != "" {
    let strs: String = showPhoneNumber
    let x = strs.substringWithRange(Range<String.Index>(start: strs.startIndex.advancedBy(0), end: strs.endIndex.advancedBy(-1)))
    
    showPhoneNumber = x
    }else{
    showPhoneNumber = showStartPhoneNumber
    checkFirstClick = true
    }
    inputPhoneNumber.text = "\(showPhoneNumber)"
    }
    }*/

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "AudioCall") {
            // pass data to next view
            if let destination: CallOutDemoViewController = segue.destinationViewController as? CallOutDemoViewController {
                destination.nameTitle = test.text!;
                destination.numTitle = test.text!;
                appDelegate.pressNumpadButton(13)
                appDelegate.makeCall(test.text!, videoCall: false)
                
            }
        }
    }
    
    //
    // MARK: required methods for keyboard delegate protocol
    //
    /*
    func initializeCustomKeyboard() {
        // initialize custom keyboard
        //let keyboardView = Keyboard(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        
        // the view controller will be notified by the keyboard whenever a key is tapped
        keyboardView!.delegate = self
        
        // required for backspace to work
        inputPhoneNumber.delegate = self
        
        // replace system keyboard with custom keyboard
        //inputPhoneNumber.inputView = keyboardView
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView!.delegate = self
    
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
        
        showUname.text = "User Name : \(readString[readString.startIndex..<result!.startIndex])"
    }
    
    func keyWasTapped(character: String) {
        textNum = "\(textNum)\(character)"
        test.text = textNum
    }
    
    func backspace() {
        if(textNum.characters.count > 0){
            textNum = textNum.substringToIndex(textNum.endIndex.predecessor())
            test.text = textNum
        }
    }
    
    func call_btn(enable: Bool) {
        
        if(appDelegate.checkNetwork){
            //for show display name when calling
            appDelegate.return_displayName(test.text!)
            sleep(1)
            
            callOut = storyboard!.instantiateViewControllerWithIdentifier("AudioCall") as UIViewController
            
            appDelegate.callFromNumpadNum = test.text!
        
            appDelegate.callFromNumpadName = "\(HistoryData.displayName)"

        
            appDelegate.makeCall(test.text!, videoCall: false)
            
            appDelegate.pressNumpadButton(13)
            
            HistoryData.call_action.insert("callOut", atIndex: 0)

            HistoryData.data.insert(HistoryData.displayName, atIndex: 0)
            HistoryData.num.insert(phoneNumber, atIndex: 0)
            HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
            print("HISTORY name : \(HistoryData.data), num : \(HistoryData.num)")
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
            
            print("###########phone number is \(test.text)###########")
            
            let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            callOut.modalTransitionStyle = modalStyle
        
            presentViewController(callOut, animated: true, completion: nil)
        }else{
            print("cancel call")
            showAlert("ERROR", message: "Plase connect KKU Wifi(or VPN) for use this App......\n\nSystem will automatic cancel call", btn: "OK")
            test.text = "CANCEL CALL"
            textNum = ""
            
        }
        
    }
    
    func showAlert(title: String, message: String, btn: String) {
        let createAccountErrorAlert: UIAlertView = UIAlertView()
        
        createAccountErrorAlert.delegate = self
        
        createAccountErrorAlert.title = title
        createAccountErrorAlert.message = message
        createAccountErrorAlert.addButtonWithTitle(btn)

        
        createAccountErrorAlert.show()
    }
    
    /*
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    */
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
    
    func inputPhoneNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 5 // Bool
    }
}