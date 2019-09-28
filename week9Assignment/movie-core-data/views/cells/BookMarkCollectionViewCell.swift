//
//  BookMarkCollectionViewCell.swift
//  movie-core-data
//
//  Created by Su Win Phyu on 9/28/19.
//  Copyright © 2019 padc. All rights reserved.
//

import UIKit

class BookMarkCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BookMarkCollectionViewCell"
    
    @IBOutlet weak var imgViewBookMarkMovie: UIImageView!
    
    var data : MovieVO? {
        didSet {
            if let data = data {
                imgViewBookMarkMovie.sd_setImage(with: URL(string: "\(API.BASE_IMG_URL)\(data.poster_path ?? "")"), completed: nil)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    
}
