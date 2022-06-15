//
//  Comment.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

class CommentKeys {
    static let typeKey = "Comment"
    static let timestampKey = "timestamp"
    static let textKey = "text"
    static let postReference = "postReference"
}

class Comment {
    var text: String
    var timestamp: Date
    var postReference: CKRecord.Reference?
    
    var recordID: CKRecord.ID
    
    
    init(text: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID.init(recordName: UUID().uuidString), postReference: CKRecord.Reference?) {
        self.text = text
        self.timestamp = timestamp
        self.recordID = recordID
        self.postReference = postReference
    }
    
}

extension Comment {
    convenience init?(ckRecord: CKRecord) {
        guard let text = ckRecord[CommentKeys.textKey] as? String,
              let timestamp = ckRecord[CommentKeys.timestampKey] as? Date else {return nil}
        
        let postReference = ckRecord[CommentKeys.postReference] as? CKRecord.Reference
        
        self.init(text: text, timestamp: timestamp, recordID: ckRecord.recordID, postReference: postReference)
              
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        self.init(recordType: CommentKeys.typeKey, recordID: comment.recordID)
        
        self.setValuesForKeys([CommentKeys.timestampKey : comment.timestamp,
                               CommentKeys.textKey : comment.text])
        
        if let reference = comment.postReference {
            self.setValue(reference, forKey: CommentKeys.postReference)
        }
                               
        
    }
}
