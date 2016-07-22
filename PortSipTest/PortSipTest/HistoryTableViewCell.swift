//
//  HistoryTableViewCell.swift
//  PortSipTest
//
//  Created by RnD on 7/21/2559 BE.
//  Copyright © 2559 RnD. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var subtilte: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
