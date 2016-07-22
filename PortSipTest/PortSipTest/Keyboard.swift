//
//  Keyboard.swift
//  Numbers Keyboard
//
//  Created by Dan Livingston  on 3/30/16.
//  Copyright © 2016 Zombie Koala. All rights reserved.
//

import UIKit

// The view controller will adopt this protocol (delegate)
// and thus must contain the keyWasTapped method
protocol KeyboardDelegate: class
{
    func keyWasTapped(character: String)
    func backspace()
    func call_btn(enable : Bool)
}
var phoneNumber = ""

class Keyboard: UIView {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    // This variable will be set as the view controller so that`
    // the keyboard can send messages to the view controller.
    weak var delegate: KeyboardDelegate?
    
    var enableCall = false
    // MARK:- keyboard initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    func initializeSubviews() {
        let xibFileName = "Keyboard" // xib extention not included
        let view = NSBundle.mainBundle().loadNibNamed(xibFileName, owner: self, options: nil)[0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        phoneNumber = ""
    }
    
    // MARK:- Button actions from .xib file
    
    @IBAction func keyTapped(sender: UIButton) {
        // When a button is tapped, send that information to the
        // delegate (ie, the view controller)
        phoneNumber = "\(phoneNumber)\(sender.titleLabel!.text!)"
        
        
        if(phoneNumber.characters.count <= 5){
            self.delegate?.keyWasTapped(sender.titleLabel!.text!) // could alternatively send a tag value
        }else{
            phoneNumber = phoneNumber.substringToIndex(phoneNumber.endIndex.predecessor())
        }
    }

    @IBAction func backspace(sender: UIButton) {
        if(phoneNumber.characters.count > 0){
            phoneNumber = phoneNumber.substringToIndex(phoneNumber.endIndex.predecessor())
        }
        
        self.delegate?.backspace()
    }
    @IBAction func call_btn(enable: Bool) {
        print("call :\(phoneNumber)")
        if(phoneNumber.characters.count == 5) {
            enableCall = true
            self.delegate?.call_btn(enableCall)
            phoneNumber = ""
        }
        
        enableCall = false
        
    }
    
    

}
