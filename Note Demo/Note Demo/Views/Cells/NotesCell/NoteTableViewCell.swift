//
//  NoteTableViewCell.swift
//  Note Demo
//
//  Created by Debashish Das on 30/09/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updatedAtLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var categoryColorView: UIView!
    static let cellID = "NoteCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
