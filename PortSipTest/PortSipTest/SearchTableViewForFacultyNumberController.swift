//
//  SearchTableViewForFacultyNumberController.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit


@available(iOS 8.0, *)
class SearchTableViewForFacultyNumberController: UITableViewController, UISearchResultsUpdating, CallAPIProtocol {
    
    
    var feedItem: NSArray = NSArray()
    var tableData =  [String: String]()
    var keyData = [String]()
    var valueData = [String]()
    var filter = [String]()
    var searchResult = UISearchController()
    
    var facultyID: String = ""
    
    //call variable
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.checkNetwork = false
        self.searchResult = UISearchController(searchResultsController: nil)
        self.searchResult.searchResultsUpdater = self
        
        self.searchResult.dimsBackgroundDuringPresentation = false
        self.searchResult.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.searchResult.searchBar
        
        // Call API
        let callFacultyNumber = CallFacultyNumber()
        callFacultyNumber.delegate = self
        sleep(1/2)
        callFacultyNumber.downloadItems("https://api.kku.ac.th/phonedirectory/getPhone/"+facultyID)
        sleep(1/2)
        self.tableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func itemsDownloaded(items: NSArray) {
        
        feedItem = items
        if(feedItem == []) {
            
            print("empty array")
            showAlert("ERROR", message: "No data in kku phone directory", btn: "OK")
        }
        print("=================Search Table View==========================\(feedItem)")
        updateFaculty()
        keyData = Array(tableData.keys).sort(<)
        valueData = Array(tableData.values)
        self.tableView.reloadData()
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchResult.active {
            return self.filter.count
        } else {
            return self.keyData.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell2", forIndexPath: indexPath) as UITableViewCell?

        if self.searchResult.active {
            cell!.textLabel?.text = self.filter[indexPath.row]
            cell?.detailTextLabel?.text = self.keyData[indexPath.row]
        } else {
            cell?.textLabel?.text = self.tableData[keyData[indexPath.row]]
            cell?.detailTextLabel?.text = self.keyData[indexPath.row]
        }

        return cell!
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.filter.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchResult.searchBar.text!)
        
        let array = (self.valueData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        self.filter = array as! [String]
        
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    
        self.performSegueWithIdentifier("callFromContacts", sender: self)
        
    }
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "callFromContacts")
        {
            let upcoming: CallOutDemoViewController = segue.destinationViewController as! CallOutDemoViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            if self.searchResult.active {
                upcoming.nameTitle = self.filter[indexPath.row]
                upcoming.numTitle = self.keyData[indexPath.row]
            } else {
                upcoming.nameTitle = self.tableData[keyData[indexPath.row]]
                upcoming.numTitle = self.keyData[indexPath.row]
            }
            
            HistoryData.call_action.insert("callOut", atIndex: 0)
            HistoryData.time.insert(HistoryData().updateTime(), atIndex: 0)
            HistoryData().saveHistory(HistoryData.data, phoneNumber: HistoryData.num, status: HistoryData.call_action, time: HistoryData.time)
            appDelegate.pressNumpadButton(13)
            
            //check ','
            if upcoming.numTitle!.lowercaseString.rangeOfString(",") != nil {//found
                //print("\(m.lowercaseString.rangeOfString(","))")
                let trimmedString = checkString("\(upcoming.numTitle!)",filter: ",").stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet()
                )
                upcoming.numTitle! = trimmedString
            }
            
            //check '-'
            if upcoming.numTitle!.lowercaseString.rangeOfString("-") != nil {//found
                //print("\(m.lowercaseString.rangeOfString(","))")
                let trimmedString = checkString("\(upcoming.numTitle!)",filter: "-").stringByTrimmingCharactersInSet(
                    NSCharacterSet.whitespaceAndNewlineCharacterSet()
                )
                upcoming.numTitle! = trimmedString
            }
            
            appDelegate.makeCall(upcoming.numTitle!, videoCall: false)
            
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
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
            //dataSelected = data[start..<data.endIndex]
            dataSelected = data[data.startIndex..<start.predecessor()]
        }
        
        return dataSelected
    }
    
    
    
    
    // MAKE -- UPDATE FACULTY DATA
    
    func updateFaculty(){
        var temp1: String
        var temp2 = ""
        var temp3 = ""
        var flag1 = true
        var flag2 = true
        
        for c in 0..<feedItem.count {
            temp1 = feedItem[c].description
            for i in temp1.characters{
                if i != ":" && flag1{
                    
                    temp2.append(i)
                    
                } else if flag2 {
                    
                    flag1 = false
                    flag2 = false
                    
                } else {
                    
                    temp3.append(i)
                    
                }
            }
            if(temp2 != "" && temp3 != "") {
            tableData.updateValue(temp3, forKey: temp2)
            }
            temp2 = ""
            temp3 = ""
            flag1 = true
            flag2 = true
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
}
