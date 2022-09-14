//
//  SeatTableViewCell.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import UIKit

class SeatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var vacancyImage: UIView! {
        didSet {
            vacancyImage.layer.cornerRadius = vacancyImage.bounds.height / 2
        }
    }
    @IBOutlet weak var seatType: UIImageView! {
        didSet {
            seatType.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var peopleLabel: UILabel! {
        didSet {
            peopleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        }
    }
    
    @IBOutlet weak var concentImage: UIImageView! {
        didSet {
            concentImage.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var tabacoImage: UIImageView! {
        didSet {
            tabacoImage.contentMode = .scaleAspectFill
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
