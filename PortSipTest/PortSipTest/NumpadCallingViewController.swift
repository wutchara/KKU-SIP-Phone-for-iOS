//
//  NumpadCallingViewController.swift
//  PortSipTest
//
//  Created by RnD on 7/6/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class NumpadCallingViewController: UIViewController{
    var viaSegue_name = "rachadach && chantamanee"
    var viaSegue_phoneNumber = "H && G"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //check button activity
    var checkClick_microphone: Bool = false
    var checkClick_spreaker: Bool = false
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    
    @IBAction func hungupBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func spreakerBtn(sender: AnyObject) {
        checkClick_spreaker = !checkClick_spreaker
        if (checkClick_spreaker){
            toggleImageBtn(sender as! UIButton, from: "spreaker_default", to: "spreaker_active")
        }else{
            toggleImageBtn(sender as! UIButton, from: "spreaker_active", to: "spreaker_default")
        }
    }
    @IBAction func microphoneBtn(sender: AnyObject) {
        checkClick_microphone = !checkClick_microphone
        if (checkClick_microphone){
            toggleImageBtn(sender as! UIButton, from: "microphone_default", to: "microphone_active")
            appDelegate.muteAllCall()
        }else{
            toggleImageBtn(sender as! UIButton, from: "microphone_active", to: "microphone_default")
            appDelegate.unMuteAllCall()
        }
    }
    
    func toggleImageBtn(button: UIButton, from: String, to: String) {
        if let image = UIImage(named: from) {
            button.setImage(UIImage(named: to), forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("\(viaSegue_name), \(viaSegue_phoneNumber)")
        name.text = "\(viaSegue_name) : \(viaSegue_phoneNumber)"
        
        view.endEditing(true)
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
