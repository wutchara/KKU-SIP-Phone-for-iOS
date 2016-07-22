//
//  CallOutDemoViewController.swift
//  PortSipTest
//
//  Created by RnD on 6/21/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit
class CallOutDemoViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var timer: UILabel!
    
    @IBOutlet weak var num: UILabel!
    var nameTitle: String?
    var numTitle: String?
    // call variable
    var mute = false
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //check button activity
    var checkClick_microphone: Bool = false
    var checkClick_spreaker: Bool = false
    
    @IBAction func cancel(sender: AnyObject) {
        if let n = nameTitle , m = numTitle{
        
            HistoryData.data.insert(n, atIndex: 0)
        
            HistoryData.num.insert(m, atIndex: 0)
            
            print("update history success!!")
        
            print("name: \(HistoryData.data) num: \(HistoryData.num)")
            print()
            
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        } else {
            print("Call from numpad")
            
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
            
            let tabbar: UITabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("tabbar") as! UITabBarController
            
            let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            tabbar.modalTransitionStyle = modalStyle
            
            presentViewController(tabbar, animated: true, completion: nil)
            
        }
        
        //hang Up method
        
        appDelegate.pressNumpadButton(14)
        appDelegate.hungUpCall()
    }
    @IBAction func spreaker(sender: AnyObject) {
        checkClick_spreaker = !checkClick_spreaker
        if (checkClick_spreaker){
            toggleImageBtn(sender as! UIButton, from: "spreaker_default", to: "spreaker_active")
            appDelegate.setLoudspeakerStatus(false)
        }else{
            toggleImageBtn(sender as! UIButton, from: "spreaker_active", to: "spreaker_default")
            appDelegate.setLoudspeakerStatus(true)
        }
    }
    @IBAction func microphone(sender: AnyObject) {
        print("\(HistoryData.displayName)")
        checkClick_microphone = !checkClick_microphone
        if (checkClick_microphone){
            toggleImageBtn(sender as! UIButton, from: "microphone_default", to: "microphone_active")
            appDelegate.muteCall(false)
        }else{
            toggleImageBtn(sender as! UIButton, from: "microphone_active", to: "microphone_default")
            appDelegate.muteCall(true)
        }
    }
    
    
    func toggleImageBtn(button: UIButton, from: String, to: String) {
        if UIImage(named: from) != nil {
            button.setImage(UIImage(named: to), forState: .Normal)
        }
    }
    
    //default select last
    func checkString(data: String, filter: String)-> String{
        var dataSelected: String = ""
        // Search for one string in another.
        let result = data.rangeOfString(filter,
                                        options: NSStringCompareOptions.LiteralSearch,
                                        range: data.startIndex..<data.endIndex,
                                        locale: nil)
        
        // See if string was found.
        if let range = result {
            // Start of range of found string.
            let start = range.startIndex.successor()
            print(data.debugDescription)
            // Display string starting at first index.
            print("last :  \(data[start..<data.endIndex])")
            // Display string before first index.
            print("Other : \(data[data.startIndex..<start.predecessor()])")
            
            //select last index
            dataSelected = data[data.startIndex..<start.predecessor()]
        }
        
        return dataSelected
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let n = nameTitle, m = numTitle{
            name.text = n
            
            //check ','
            if m.lowercaseString.rangeOfString(",") != nil {//found
                //print("\(m.lowercaseString.rangeOfString(","))")
                let trimmedString = checkString("\(m)",filter: ",").stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet()
                )
                num.text = trimmedString
            }else{
                num.text = m
            }
            
            //check '-'
            if m.lowercaseString.rangeOfString("-") != nil {//found
                //print("\(m.lowercaseString.rangeOfString(","))")
                let trimmedString = checkString("\(m)",filter: "-").stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet()
                )
                num.text = trimmedString
            }else{
                num.text = m
            }
        } else {
            name.text = appDelegate.callFromNumpadName
            
            num.text = appDelegate.callFromNumpadNum
        }
        // Do any additional setup after loading the view.
        timer.hidden = true
        var time = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CallOutDemoViewController.updateTime), userInfo: nil, repeats: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    override func viewDidAppear(animated: Bool) {
        if let _ = nameTitle, _ = numTitle {
            
        } else {
        name.text = appDelegate.nameIncomingCall
        self.view.reloadInputViews()
        }
    }
    */
    var hh = 0
    var mm = 0
    var ss = 0
    var timeCount = 0
    func updateTime() {
        if(appDelegate.isAcceptCall) {
            timer.hidden = false
            timeCount += 1
            
            if(timeCount < 60) {
                ss = timeCount
            } else {
                mm += 1
                ss = 0
                timeCount = 0
            }
            
            if(mm > 59) {
                hh += 1
                mm = 0
            }
            
            if(hh > 23) {
                hh = 0
            }
            
            if(mm < 10 && ss < 10) {
                timer.text = "\(hh):0\(mm):0\(ss)"
            } else if(mm < 10) {
                timer.text = "\(hh):0\(mm):\(ss)"
            } else if(ss < 10) {
                timer.text = "\(hh):\(mm):0\(ss)"
            } else {
                timer.text = "\(hh):\(mm):\(ss)"
            }
            
            
        }else{
            timer.hidden = true
            ss = 0
            timeCount = 0
            mm = 0
            hh = 0
        }
    }
}
