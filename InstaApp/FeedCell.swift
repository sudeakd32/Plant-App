//
//  FeedCell.swift
//  InstaApp
//
//  Created by Sude on 19.06.2025.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var commentTextField: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var emailTextField: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
