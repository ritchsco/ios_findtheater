//
//  FeaturedCollectionViewCell.swift
//  MovieNight
//
//  Created by Shannon Lim on 2020-03-20
//
//  Purpose: Provides the outlets to the storyboard defining a custom Collection View Cell

import UIKit

class FeaturedCollectionViewCell: UICollectionViewCell {
    @IBOutlet var featuredImage : UIImageView!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblReleaseDate : UILabel!
}
