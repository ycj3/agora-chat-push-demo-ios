//
//  GroupListCell.swift

//
//  Created by Carlson Yuan on 2023/8/7.
//

import UIKit
import AgoraChat

open class GroupListCell: InsetGroupTableViewCell {
            
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var groupSubTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    open func configure(with group: AgoraChatGroup) {
            groupTitleLabel.text = group.groupName
            groupSubTitleLabel.text = group.description
    }
    
}
