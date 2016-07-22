//
//  TableViewController.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
class SearchTableViewController: UITableViewController, UISearchResultsUpdating, CallAPIProtocol {
    
    var feedItem: NSArray = NSArray()
    var tableData =  [String: String]()
    var keyData = [String]()
    var valueData = [String]()
    var filter = [String]()
    var searchResult = UISearchController()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchResult = UISearchController(searchResultsController: nil)
        self.searchResult.searchResultsUpdater = self
        
        self.searchResult.dimsBackgroundDuringPresentation = false
        self.searchResult.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.searchResult.searchBar
        
        if(keyData == [] && valueData == []) {
        //======CallAPI
        let callDepartmentID = CallDepartmentID()
        callDepartmentID.delegate = self
        callDepartmentID.downloadItems("https://api.kku.ac.th/phonedirectory/getDepartment")
        print("download phone directory data")
            
        }
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func itemsDownloaded(items: NSArray) {
        
        feedItem = items
        updateDepartment()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell?
        
        if self.searchResult.active {
            
            cell!.textLabel?.text = self.filter[indexPath.row]
        } else {
            cell?.textLabel?.text = self.tableData[keyData[indexPath.row]]
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
        
        self.performSegueWithIdentifier("showFacultyView", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "showFacultyView")
        {
            let upcoming: SearchTableViewForFacultyNumberController = segue.destinationViewController as! SearchTableViewForFacultyNumberController
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            let facultyID = keyData[indexPath.row]
            
            upcoming.facultyID = facultyID
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        
    }

    func updateDepartment(){
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
            
            tableData.updateValue(temp3, forKey: temp2)
            temp2 = ""
            temp3 = ""
            flag1 = true
            flag2 = true
        }
    }

}
