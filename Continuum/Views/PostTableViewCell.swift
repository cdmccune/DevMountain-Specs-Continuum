//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    //MARK: - Properties
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var captionLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    
    //MARK: - Helper Functions
    func updateViews() {
        guard let post = post else {return}
        postImage.image = post.photo
        captionLabel.text = post.caption
        commentLabel.text = "Comments: \(post.commentCount)"
    }

}
