//
//  AppDelegate.swift
//  PortSipTest
//
//  Created by RnD on 6/21/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, PortSIPEventDelegate {

    var window: UIWindow?
    var session = Session()
    var login = Login(username: "", displayName: "test", auth: "", passwd: "", domain: "", server: "202.28.116.46")
    var sipRegistered = false
    
    var nameIncomingCall = ""
    
    var numIncomingCall = ""
    
    var callFromNumpadName = ""
    
    var checkNetwork: Bool = false
    
    var callFromNumpadNum = ""
    
    var audioPermission = AVAudioSession.sharedInstance()
    
    var portSIP = PortSIPSDK()
    
    var mSoundService: SoundService!
    var internetReach = Reachability()
    
    var pathSaveFile: NSURL = NSURL()
    
    var misscallType = false
    
    var isAcceptCall = false
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.mSoundService = SoundService()
        print(HistoryData.data)
        
        UISearchBar.appearance().barTintColor = UIColor(red: 150.0/255.0, green: 40.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        UISearchBar.appearance().tintColor = UIColor.whiteColor()
        if #available(iOS 9.0, *) {
            UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor(red: 150.0/255.0, green: 40.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        } else {
            // Fallback on earlier versions
        }
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 1.0)
        
        // portSIPLib setup
        portSIP = login.portSIP
        portSIP.delegate = self
        internetReach = Reachability.reachabilityForInternetConnection()
        internetReach.startNotifier()
        print(portSIP)
        
        if #available(iOS 8.0, *) {
            if UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings)){
                UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings.init(forTypes: [.Alert, .Badge, .Sound], categories: nil))
            }
           
        }

        self.microphoneWithPermission()

        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        portSIP.startKeepAwake()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        portSIP.stopKeepAwake()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func trim_displayname(str: String)-> String {
        var temp: String = ""
        
        let result = str.rangeOfString("Optional",
                                        options: NSStringCompareOptions.LiteralSearch,
                                        range: str.startIndex..<str.endIndex,
                                        locale: nil)
        if let range = result {
            // Start of range of found string.
            let start = range.startIndex
            
            // Display string starting at first index.
            temp = str[start.advancedBy(9)..<str.endIndex.predecessor()]
        }

        return temp
    }
    
    func checkKKUWifi(){
        let requestURL: NSURL = NSURL(string: "https://api.kku.ac.th/")!
        let urlRequest: NSURLRequest = NSURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            print("\(response) -------- \(data) -------- \(response) ")
            
            if let httpResponse = response as? NSHTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("---------------------\(statusCode)")
                if (statusCode == 200) {
                    self.checkNetwork = true
                    /*
                     //for show display name when calling
                     self.appDelegate.return_displayName(self.test.text!)
                     sleep(1)
                     
                     self.callOut = self.storyboard!.instantiateViewControllerWithIdentifier("AudioCall") as UIViewController
                     
                     self.appDelegate.makeCall(self.test.text!, videoCall: false)
                     
                     self.appDelegate.pressNumpadButton(13)
                     
                     print("###########phone number is \(self.test.text)###########")
                     
                     let modalStyle: UIModalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                     
                     self.callOut.modalTransitionStyle = modalStyle
                     
                     self.presentViewController(self.callOut, animated: true, completion: nil)*/
                }
                
                //print(statusCode)
            } else {
                print("no status code")
                print("ERROR : not connect KKU wifi")
                self.checkNetwork = false
            }
        }
        
        task.resume()
        
    }
    
    func return_displayName(userName: String){
        var userDisplayName: String = ""
        let requestURL: NSURL = NSURL(string: "http://dev01.thai3dprint.com/repos/cloud/testLangugeAPI.php?page=user_kku")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            //print(statusCode)
            if (statusCode == 200) {//200 is found and can use
                //print("Everyone is fine, file downloaded successfully.")
                
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    for s in 0..<(json.count){
                        print("\(json[s]["user_name"]) : \(json[s]["display_name"])")
                        print("=================================================================")
                        
                        let tempName: String = "\(json[s]!["user_name"]!)"

                        print("user name : \(Int(userName)) == \(tempName)")
                        
                        if("\(Int(userName))" == "\(tempName)"){
                            userDisplayName = "\(json[s]["display_name"])"
                            print("Found Display Name : \(userDisplayName)")
                            
                            
                            HistoryData.displayName = self.trim_displayname(userDisplayName)
                            print("Data update : \(HistoryData.displayName)")
                            
                            /*
                            // Save data to file
                            let fileName = "kkuUN"
                            let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
                            let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")

                            let writeString = userDisplayName
                            do {
                                // Write to the file
                                try writeString.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
                            } catch let error as NSError {
                                print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
                            }
                            print("Save File Success")
                            //end save name
                            
                            
                            //read file
                            var readString = "" // Used to store the file contents
                            do {
                                // Read the file contents
                                readString = try String(contentsOfURL: fileURL)
                            } catch let error as NSError {
                                print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
                            }
                            HistoryData.displayName = [readString]
                            print("Read File Success : \(readString)")
                            print(HistoryData.displayName)*/
                        }
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        
        task.resume()
    }
    
    // MAKE --
    
    func pressNumpadButton(dtmf: Int32) {
        
        if(session.sessionState) {
            portSIP.sendDtmf(session.sessionId, dtmfMethod: DTMF_RFC2833, code: dtmf, dtmfDration: 160, playDtmfTone: true)
        }
        
    }
    
    func setLoudspeakerStatus(enable: Bool) {
        portSIP.setLoudspeakerStatus(enable)
        
    }
    
    func incomingNumParse(caller: String) -> String {
       
        
        let temp = caller.startIndex.advancedBy(4)
        let temp2 = caller.startIndex.advancedBy(9)
        
        return "\(caller[temp..<temp2])"
    }
    
    
    
    
    // MAKE -- CALL FUNCTION
    
    func makeCall(callee: String, videoCall: Bool) {
        if(session.sessionState || session.recvCallState) {
            print("session busy")
            return
            
        }
        
        let sessionId:Int = portSIP.call(callee, sendSdp: true, videoCall: videoCall)
        
        if(sessionId >= 0) {
            //select sesionId
            session.sessionId = sessionId
            session.sessionState = true
            session.videoState = videoCall
            
            print("Calling \(callee) on line \(sessionId)")
            
        } else {
            print("make call fialure errorCode = \(sessionId)")
            
        }
    }
    
    func hungUpCall() {
        if(session.sessionState) {
            portSIP.hangUp(session.sessionId)
            session.reset()
            print("hangUp call on line \(session.sessionId)")
            
        } else if(session.recvCallState) {
            portSIP.rejectCall(session.sessionId, code: 486)
            session.reset()
            
            print("reject call \(session.sessionId)")
            
        }
        
        mSoundService.stopRingTone()
        mSoundService.stopRingBackTone()
        self.setLoudspeakerStatus(false)
        isAcceptCall = false
        
    }
    
    func muteCall(mute: Bool) {
        if(session.sessionState) {
            if(!mute) {
                portSIP.muteSession(session.sessionId, muteIncomingAudio: true, muteOutgoingAudio: true, muteIncomingVideo: true, muteOutgoingVideo: true)
                print("mute")
                
            } else {
                portSIP.muteSession(session.sessionId, muteIncomingAudio: false, muteOutgoingAudio: false, muteIncomingVideo: false, muteOutgoingVideo: false)
                print("unmute")
                
            }
            
        }
        
    }
    
    
    
    
    
    
    // MAKE -- REGISTER EVENT
    
    func onRegisterSuccess(statusText: UnsafeMutablePointer<Int8>, statusCode: Int32) {
        sipRegistered = true
        login.onRegisterSuccess(statusCode, statusText: statusText)
        
    }
    
    func onRegisterFailure(statusText: UnsafeMutablePointer<Int8>, statusCode: Int32) {
        sipRegistered = false
        login.onRegisterFailure(statusCode, statusText: statusText)
        
    }
    
    
    
    
    
    // MAKE -- CALLBACK EVENT
    
    func onInviteIncoming(sessionId: Int, callerDisplayName: UnsafeMutablePointer<Int8>, caller: UnsafeMutablePointer<Int8>, calleeDisplayName: UnsafeMutablePointer<Int8>, callee: UnsafeMutablePointer<Int8>, audioCodecs: UnsafeMutablePointer<Int8>, videoCodecs: UnsafeMutablePointer<Int8>, existsAudio: Bool, existsVideo: Bool) {
        
        if(!session.sessionState && !session.recvCallState) {
            session.recvCallState = true
        }
        
        if(!session.recvCallState) {
            portSIP.rejectCall(sessionId, code: 486)
            print("auto reject call")
            return
        }
        
        session.sessionId = sessionId
        session.videoState = existsVideo
        print("Call Established on line \(sessionId)")
        
        nameIncomingCall = String(UTF8String: UnsafePointer<CChar>(callerDisplayName))!
        
        numIncomingCall = String(UTF8String: UnsafePointer<CChar>(caller))!
        
        numIncomingCall = self.incomingNumParse(numIncomingCall)
        
        print("Incoming call \(caller)")
        mSoundService.playRingTone()
        
        
        if(UIApplication.sharedApplication().applicationState == UIApplicationState.Background) {
            let localNotif = UILocalNotification()
            localNotif.alertBody = "Call from \(String(UTF8String: UnsafePointer<CChar>(callerDisplayName))!) \(String(UTF8String: UnsafePointer<CChar>(caller))!) on line \(index)"
            localNotif.soundName = UILocalNotificationDefaultSoundName
            localNotif.applicationIconBadgeNumber = 1
            
            UIApplication.sharedApplication().presentLocalNotificationNow(localNotif)
            
        }
    
        
        // for ios 8.0 up
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewControllerWithIdentifier("answer") as UIViewController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
        
    }
    
    
    func onInviteTrying(sessionId: Int) {
        print("Call is trying on line \(sessionId)")
        
    }
    
    func onInviteSessionProgress(sessionId: Int, audioCodecs: UnsafeMutablePointer<Int8>, videoCodecs: UnsafeMutablePointer<Int8>, existsEarlyMedia: Bool, existsAudio: Bool, existsVideo: Bool) {
        let index = session.sessionId
        if (index != sessionId){
            return
        }
        
        session.existEarlyMedia = existsEarlyMedia
        
    }
    
    func onInviteRinging(sessionId: Int, statusText: UnsafeMutablePointer<Int8>, statusCode: Int32) {
        
        if(session.sessionId != sessionId) {
        
            return
            
        }
        
        mSoundService.playRingBackTone()
        
        print("Call ringing on line \(session.sessionId)")
        
    }
    
    func onInviteAnswered(sessionId: Int, callerDisplayName: UnsafeMutablePointer<Int8>, caller: UnsafeMutablePointer<Int8>, calleeDisplayName: UnsafeMutablePointer<Int8>, callee: UnsafeMutablePointer<Int8>, audioCodecs: UnsafeMutablePointer<Int8>, videoCodecs: UnsafeMutablePointer<Int8>, existsAudio: Bool, existsVideo: Bool) {
        
        if(session.sessionId != sessionId) {
            return
        }
        
        session.sessionState = true
        session.videoState = existsVideo
        
        if(session.isReferCall) {
            session.isReferCall = false
            session.originCallSessionId = -1
        }
        
        mSoundService.stopRingBackTone()
        
    }
    
    func onInviteFailure(sessionId: Int, reason: UnsafeMutablePointer<Int8>, code: Int32) {
        if(session.sessionId != sessionId) {
            return
        }
        
        if(session.isReferCall) {
            if(session.sessionId == session.originCallSessionId) {
                portSIP.unHold(session.originCallSessionId)
                session.holdState = false
                
                print("current line = \(session.originCallSessionId)")
            }
            
        }
        
        print("onInviteFailure")
        session.reset()
        mSoundService.stopRingTone()
        mSoundService.stopRingBackTone()
        self.setLoudspeakerStatus(true)
        
    }
    
    func onInviteUpdated(sessionId: Int, audioCodecs: UnsafeMutablePointer<Int8>, videoCodecs: UnsafeMutablePointer<Int8>, existsAudio: Bool, existsVideo: Bool) {
        if(session.sessionId != sessionId) {
            return
        }
        
    }
    
    func onInviteConnected(sessionId: Int) {
        if(session.sessionId != sessionId) {
            return
        }
        
        print("onInviteConnected..")
        isAcceptCall = true
        setLoudspeakerStatus(false)
        
        
    }
    
    func onInviteBeginingForward(forwardTo: UnsafeMutablePointer<Int8>) {
        
    }
    
    func onInviteClosed(sessionId: Int) {
        if(session.sessionId != sessionId) {
            return
        }
        
        print("Call close by remote on line\(sessionId)")
        
        session.reset()
        
        mSoundService.stopRingTone()
        mSoundService.stopRingBackTone()
        self.setLoudspeakerStatus(true)
        
        print("onInviteClose..")
        
        if(misscallType) {
            misscallType = false
        } else {
            HistoryData.call_action.insert("missCall", atIndex: 0)
        }
        HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
        HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
        
        isAcceptCall = false
        
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let close: UITabBarController = mainStoryboard.instantiateViewControllerWithIdentifier("tabbar") as! UITabBarController
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = close
        self.window?.makeKeyAndVisible()
        
    }
    
    
  
    
    
    
    // MARK -- Signaling event
    
    func onReceivedSignaling(sessionId: Int, message: UnsafeMutablePointer<Int8>) {
        
        
    }
    
    func onSendingSignaling(sessionId: Int, message: UnsafeMutablePointer<Int8>) {
        
        
    }
    
    
    
    
    
    
    
    // MARK -- RTP/Audio/Video stream callback data
    
    func onReceivedRTPPacket(sessionId: Int, isAudio: Bool, RTPPacket: UnsafeMutablePointer<UInt8>, packetSize: Int32) {
        
        
    }
    
    func onSendingRTPPacket(sessionId: Int, isAudio: Bool, RTPPacket: UnsafeMutablePointer<UInt8>, packetSize: Int32) {
        
        
    }
    
    func onAudioRawCallback(sessionId: Int, audioCallbackMode: Int32, data: UnsafeMutablePointer<UInt8>, dataLength: Int32, samplingFreqHz: Int32) {
        
        
    }
    
    func onVideoRawCallback(sessionId: Int, videoCallbackMode: Int32, width: Int32, height: Int32, data: UnsafeMutablePointer<UInt8>, dataLength: Int32) {
        
        
    }
    
    
    
    
    
    
    
    // MARK -- reachability
    
    func reachablilityChanged(note: NSNotification) {
        //let curReach = note.object
       
        
    }
    
    
    
    
    
    
    
    
    
    // MARK -- interrupt handler
    
    func handleInterruption(notification: NSNotification) {
        
        let temp: [NSObject : AnyObject] = notification.userInfo!
        var flag = false
        let interrupType = temp[AVAudioSessionInterruptionTypeKey] as! AVAudioSessionInterruptionType
        
        if(interrupType == AVAudioSessionInterruptionType.Began) {
            self.holdAllCall()
            
        }
        
        if(interrupType == AVAudioSessionInterruptionType.Ended) {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                flag = true
                print("set audio success")
            } catch {
                print(error)
            }
            
        } else {
            print("set audio failure")
        }
        
        if(flag) {
            self.unholdAllCall()
        }
        
    }
    
    
    
    
    
    
    // MARK -- hold and mute method
    
    func holdAllCall() {
        portSIP.hold(session.sessionId)
        session.holdState = true
        
    }
    
    func unholdAllCall() {
        portSIP.unHold(session.sessionId)
        session.holdState = false
        
    }
    
    func muteAllCall() {
        portSIP.muteSession(session.sessionId, muteIncomingAudio: true, muteOutgoingAudio: true, muteIncomingVideo: true, muteOutgoingVideo: true)
        
    }
    
    func unMuteAllCall() {
        portSIP.muteSession(session.sessionId, muteIncomingAudio: false, muteOutgoingAudio: false, muteIncomingVideo: false, muteOutgoingVideo: false)
        
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func microphoneWithPermission() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }

    
    
    
    // MARK -- set speaker anable
    
    
    
}

