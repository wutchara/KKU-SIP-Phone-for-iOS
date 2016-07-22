//
//  Department.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

//properties
class Department: NSObject{
    var id: String?
    var name: String?
    
//empty constructor

    override init()
    {
    
    }

//construct with @name, @address, @latitude, and @longitude parameters

    init(id: String, name: String) {
    
        self.id = id
        self.name = name
    
    }


//prints object's current state

    override var description: String {
        return "\(id!):\(name!)"
    
    }

}
    