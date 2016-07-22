//
//  HistoryTableViewController.swift
//  PortSipTest
//
//  Created by RnD on 6/21/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    var image: UIImage?
    //call variable
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HistoryData().readHistoryFile()
        
        //appDelegate.return_displayName("42087")
        //appDelegate.login.setDisplayName("HAM")
        //print("HISTORY : \(HistoryData.displayName)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return HistoryData.data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell3", forIndexPath: indexPath) as! HistoryTableViewCell
        var check: Int = 0
        
        if(HistoryData.data[indexPath.row] == "") {
            HistoryData.data.removeFirst()
            HistoryData.num.removeFirst()
            HistoryData.call_action.removeFirst()
            check = 1;
        } else {
            
            switch HistoryData.call_action[indexPath.row + check] {
            case "callOut":
                image = UIImage(named: "call_out")
            case "callAnswer":
                image = UIImage(named: "call_answer")
            case "unknown": break
                
            default:
                image = UIImage(named: "call_reject")
            }
            
            cell.title?.text = HistoryData.data[indexPath.row + check]
            cell.subtilte?.text = HistoryData.num[indexPath.row + check]
            cell.photo?.image = image
            cell.time?.text = HistoryData.time[indexPath.row + check]
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        self.performSegueWithIdentifier("callFromHistory", sender: self)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            HistoryData.data.removeAtIndex(indexPath.row)
            HistoryData.num.removeAtIndex(indexPath.row)
            HistoryData.call_action.removeAtIndex(indexPath.row)
            HistoryData.time.removeAtIndex(indexPath.row)
           
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
           
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if (segue.identifier == "callFromHistory")
        {
            let upcoming: CallOutDemoViewController = segue.destinationViewController as! CallOutDemoViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            upcoming.nameTitle = HistoryData.data[indexPath.row]
            upcoming.numTitle = HistoryData.num[indexPath.row]
            
            HistoryData.call_action.insert("callOut", atIndex: 0)
            HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
            appDelegate.pressNumpadButton(13)
            appDelegate.makeCall(upcoming.numTitle!, videoCall: false)
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        } else {
          print("No sgue")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    /*
    
    func readFile(fileName: String)->String{
        //for save name
        // Save data to file
        let DocumentDirURL = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileURL = DocumentDirURL.URLByAppendingPathComponent(fileName).URLByAppendingPathExtension("txt")
        
        //read
        var readString = "" // Used to store the file contents
        do {
            // Read the file contents
            readString = try String(contentsOfURL: fileURL)
        } catch let error as NSError {
            print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }
        //end save name

        return "readString"
    }
 */
}
