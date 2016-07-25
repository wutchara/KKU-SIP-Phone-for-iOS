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
    
}
