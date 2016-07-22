//
//  Faculty.swift
//  UIMixTest
//
//  Created by RnD on 6/14/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import Foundation

class Faculty: NSObject {
    
    var name: String?
    var kku_tel: String?
    var division: String?
    var direct_tel: String?
    var division_tel: String?
    var note: String?
    
    override init(){
        
    }
    
    init(name: String, kku_tel: String, division: String, direct_tel: String, division_tel: String, note: String){
        self.name = name
        self.kku_tel = kku_tel
        self.division = division
        self.direct_tel = direct_tel
        self.division_tel = division_tel
        self.note = note
        
    }
    
    override var description: String {
        return "\(kku_tel!):\(division!)"
        
    }

}