//
//  Login.swift
//  TestSdk2
//
//  Created by RnD on 7/4/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

class Login{
    
    var portSIP = PortSIPSDK()
    var transport = TRANSPORT_UDP
    var ret: Int32?
    var lKey: Int32?
    var sessionID: Int?
    var sipURL: String = ""
    var autoRegisterTimer: NSTimer?

    var kUsername: String
    var kDisplayName: String
    var kAuthName: String
    var kPassword: String
    var kUserDomain: String
    var kSIPServer: String
    var sipInitialized = false
    var sipRegistered = false
    
    init(username: String, displayName: String,  auth: String, passwd: String, domain: String, server: String) {
        kUsername = username
        kDisplayName = displayName
        kAuthName = auth
        kPassword = passwd
        kUserDomain = domain
        kSIPServer = server

    }
    
    func setTransport(t: TRANSPORT_TYPE) {
        transport = t
        
    }
    
    func setInit() {
        ret = portSIP.initialize(transport, loglevel: PORTSIP_LOG_NONE, logPath: "", maxLine: 8, agent: "PortSIP SDK for IOS", audioDeviceLayer: 0, videoDeviceLayer: 0)
        
    }
    
    func setUserRet(localIP: String, localPort: Int32) {
        ret = portSIP.setUser(kUsername, displayName: kDisplayName, authName: kAuthName, password: kPassword, localIP: localIP, localSIPPort: localPort, userDomain: kUserDomain, SIPServer: kSIPServer, SIPServerPort: 5060, STUNServer: "", STUNServerPort: 0, outboundServer: "", outboundServerPort: 0)
        
    }
    
    func setLkey() {
        lKey = portSIP.setLicenseKey("PORTSIP_TEST_LICENSE")
        
    }
    
    func registerServer() {
        ret = portSIP.registerServer(90, retryTimes: 0)
        
    }
    
    func setUname(username: String) {
        kUsername = username
        
    }
    
    func setPass(password: String) {
        kPassword = password
    }
    
    func setDisplayName(name: String) {
        kDisplayName = name
    }
    
    
    
    
    
    
    // MAKE -- ONLINE AND OFFLINE STATUS
    
    func online() {

        if(sipInitialized){
            print("already login")
        } else {
        
            //intial
            setInit()
            if(ret != 0) {
                print("initialize failure ErrorCode = \(ret)")
                return
            } else {
                print("initialize success")
            }
        
            // when occur some error check local ip and local port define method
            var localIPaddress = "0.0.0.0"
            if (transport == TRANSPORT_TCP || transport == TRANSPORT_TLS) {
                print("###### use TCP or TLS transport ######")
                let nicNumber = portSIP.getNICNums()
                for i in 0..<nicNumber {
                    print("localIP = \(i)")
                    portSIP.getLocalIpAddress(i)
                }
                localIPaddress = portSIP.getLocalIpAddress(0)
            } else {
                print("###### use UDP transport ######")
            }
            
            let localPort:Int32  = 10000 + Int32(arc4random_uniform(1000))
            
            setUserRet(localIPaddress, localPort: localPort)
            if(ret != 0) {
                print("set user failure ErrorCode = \(ret)")
                return
            } else {
                print("set user success")
                print(localPort)
                print(localIPaddress)
            }
    
            setLkey()
            if(lKey == ECoreTrialVersionLicenseKey) {
                print("set Licenkey success")
            } else {
                print("set Licenkey failure ErrorCode = \(ret)")
                return
            }
            
            portSIP.addAudioCodec(AUDIOCODEC_PCMA)
            portSIP.addAudioCodec(AUDIOCODEC_PCMU)
            portSIP.addAudioCodec(AUDIOCODEC_SPEEX)
            portSIP.addAudioCodec(AUDIOCODEC_G729)
            portSIP.addVideoCodec(VIDEO_CODEC_H264)
            portSIP.setVideoBitrate(300)
            portSIP.setVideoFrameRate(10)
            portSIP.setVideoResolution(352, height: 288)
            portSIP.setAudioSamples(20, maxPtime: 60)
            portSIP.setVideoDeviceId(1)
            portSIP.setVideoNackStatus(true)
            portSIP.enableVideoDecoderCallback(true)
        
            registerServer()
            if(ret != 0) {
                portSIP.unInitialize()
                print("register server failure ErrorCode = \(ret)")
                return
            } else {
                print("register server success")
            }
            
            sipURL = "sip:\(kUsername):\(kUserDomain)"
            
            sipInitialized = true
        }
        
    }
    
    func offline() {

        if(sipInitialized) {
            portSIP.unRegisterServer()
            portSIP.unInitialize()
            sipInitialized = false
            
            print("logout..")
        }
        
    }
    
    func autoReRegisterTimer() {
        portSIP.refreshRegisterServer(0)
        print("process autoRegisterTimer")
        
    }
    
    func onRegisterSuccess(statusCode: Int32, statusText: UnsafeMutablePointer<Int8>)-> Int {
        sipRegistered = true
        return 0
        
    }
    
    func onRegisterFailure(statusCode: Int32, statusText: UnsafeMutablePointer<Int8>)-> Int {
        if(sipRegistered){
            autoRegisterTimer = NSTimer(timeInterval: 60, target: self, selector: "autoReRegisterTimer:", userInfo: nil, repeats: false)
        }
        return 0
        
    }
    
}