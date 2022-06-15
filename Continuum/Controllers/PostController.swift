//
//  PostController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class PostController {
    
    static var shared = PostController()
    
    var posts: [Post] = []
    
    func addComment(comment: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        
        let comment = Comment(text: comment)
        post.comments.append(comment)
        
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        
        let post = Post(photo: image, caption: caption)
        self.posts.append(post)
        
    }
}
