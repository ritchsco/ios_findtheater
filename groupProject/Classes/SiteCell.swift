//
//  SiteCell.swift
//  Week8Tables2
//
//  Created by Shannon Lim on 2020-03-06.
//
//  Purpose: Defines the look and feel of the custom Table Cell

import UIKit

class SiteCell: UITableViewCell {
    
    let primaryLabel = UILabel()
    let secondaryLabel = UILabel()
    let myImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        primaryLabel.textAlignment = .left
        primaryLabel.font = UIFont.boldSystemFont(ofSize: 25)
        primaryLabel.backgroundColor = .clear // if you have a background image by changing alpha , this makes it transparent so you can see through background image if any
        primaryLabel.textColor = .black
        
        secondaryLabel.textAlignment = .left
        secondaryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        secondaryLabel.backgroundColor = .clear
        secondaryLabel.textColor = .black
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(primaryLabel) // add to screen
        contentView.addSubview(secondaryLabel)
        contentView.addSubview(myImageView)
        
        backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        primaryLabel.frame = CGRect(x: 100, y: 5, width: 460, height: 30)
        secondaryLabel.frame = CGRect(x: 100, y: 40, width: 460, height: 30)
        myImageView.frame = CGRect(x: 5, y: 5, width: 90, height: 130)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
