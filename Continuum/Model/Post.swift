//
//  Post.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostStrings {
    static let typeKey = "Post"
    static let timestampKey = "timestamp"
    static let captionKey = "caption"
    static let commentsKey = "comments"
    static let commentCountKey = "commentCount"
    static let photoKey = "photo"
}

class Post: SearchableRecord {
    
    var recordID: CKRecord.ID
    var commentCount: Int
    var photoData: Data?
    var timestamp: Date
    var caption: String
    var comments: [Comment]
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var imageAsset: CKAsset {
        let tempDirectory = NSTemporaryDirectory()
        let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
        let fileURL = tempDirectoryURL.appendingPathComponent(recordID.recordName).appendingPathExtension(".jpg")
        do {
            try photoData?.write(to: fileURL)
        } catch let error {
            print("Error writing to temporary directory: \(error.localizedDescription)")
        }
        return CKAsset(fileURL: fileURL)
    }
    
    init(photo: UIImage?, timestamp: Date = Date(), caption: String, comments: [Comment] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), commentCount: Int = 0) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.recordID = recordID
        self.commentCount = commentCount
        self.photo = photo
    }
    
    
    func matches(searchTerm: String) -> Bool {
        return caption.lowercased().contains(searchTerm.lowercased())
    }
}

extension Post {
    convenience init?(ckrecord: CKRecord) {
        guard let caption = ckrecord[PostStrings.captionKey] as? String,
              let timestamp = ckrecord[PostStrings.timestampKey] as? Date,
              let commentCount = ckrecord[PostStrings.commentCountKey] as? Int else {return nil}
        
        var postPhoto: UIImage?
        
        if let photo = ckrecord[PostStrings.photoKey] as? CKAsset {
            do {
                guard let fileURL = photo.fileURL else {return nil}
                let data = try Data(contentsOf: fileURL)
                postPhoto = UIImage(data: data)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        self.init(photo: postPhoto, timestamp: timestamp, caption: caption, comments: [], recordID: ckrecord.recordID, commentCount: commentCount)
    }
}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostStrings.typeKey, recordID: post.recordID)
        
        self.setValuesForKeys([
            PostStrings.captionKey : post.caption,
            PostStrings.timestampKey : post.timestamp,
            PostStrings.photoKey : post.imageAsset,
            PostStrings.commentCountKey : post.commentCount
        ])
        
    }
}
