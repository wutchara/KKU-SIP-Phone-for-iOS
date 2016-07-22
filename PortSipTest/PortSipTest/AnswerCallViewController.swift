//
//  AnswerCallViewController.swift
//  PortSipTest
//
//  Created by RnD on 7/8/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerCallViewController: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var nameIncoming: UILabel!
    
    @IBOutlet weak var numIncoming: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameIncoming.text = appDelegate.nameIncomingCall
        
        numIncoming.text = appDelegate.numIncomingCall
        
        appDelegate.callFromNumpadName = nameIncoming.text!
        
        appDelegate.callFromNumpadNum = numIncoming.text!
        
        HistoryData.data.insert(nameIncoming.text!, atIndex: 0)
        
        HistoryData.num.insert(numIncoming.text!, atIndex: 0)
        
       
        // Do any additional setup after loading the view.
        view.endEditing(true)
    }

    @IBAction func answerButton(sender: AnyObject) {
        appDelegate.misscallType = true
        let nRet = appDelegate.portSIP.answerCall(appDelegate.session.sessionId, videoCall: false)
        appDelegate.mSoundService.stopRingTone()
        
        if(nRet == 0) {
            appDelegate.session.sessionState = true
            appDelegate.session.videoState = false
            
            print("Answer success")
            
        } else {
            appDelegate.session.reset()
            print("Answer Call faile")
        }
        
        let audioCall = storyboard!.instantiateViewControllerWithIdentifier("AudioCall")
        
        HistoryData.call_action.insert("callAnswer", atIndex: 0)
        HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
        HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
        appDelegate.window?.rootViewController = audioCall
        appDelegate.window?.makeKeyAndVisible()
    }
    
    @IBAction func rejectButton(sender: AnyObject) {
        appDelegate.portSIP.rejectCall(appDelegate.session.sessionId, code: 486)
        appDelegate.mSoundService.stopRingTone()
        
        HistoryData.call_action.insert("missCall", atIndex: 0)
        HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
        HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
        let tabbar: UITabBarController = storyboard?.instantiateViewControllerWithIdentifier("tabbar") as! UITabBarController
        appDelegate.window?.rootViewController = tabbar
        appDelegate.window?.makeKeyAndVisible()
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
