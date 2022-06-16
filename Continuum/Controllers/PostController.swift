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
    
    let publicDB = CKContainer.default().publicCloudDatabase
    var posts: [Post] = []
    
    func addComment(comment: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        
        
        let postReference = CKRecord.Reference(recordID: post.recordID, action: .none)
        let comment = Comment(text: comment, postReference: postReference)
        let record = CKRecord(comment: comment)
        
        
        
        publicDB.save(record) { record, error in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            guard let record = record,
                  let commentNew = Comment(ckRecord: record) else {return completion(.failure(.noComment))}
            
            self.modifyCommentCount(post: post, completion: nil)
            
            completion(.success(commentNew))
            
            
        }
        
        
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Result<Post?, PostError>) -> Void) {
        let post = Post(photo: image, caption: caption)
        let record = CKRecord(post: post)
        
        publicDB.save(record) { record, error in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            guard let record = record,
                  let postNew = Post(ckrecord: record) else {return completion(.failure(.noPost))}
            
            completion(.success(postNew))
        }
    }
    
    func fetchPosts(completion: @escaping (Result<[Post]?, PostError>) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostStrings.typeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedPosts: [Post] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                if let post = Post(ckrecord: record) {
                    fetchedPosts.append(post)
                } else {
                    return completion(.failure(.noPost))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = { result in
            switch result {
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    
                    nextOperation.qualityOfService = .userInteractive
                    
                    operation = nextOperation
                    
                    self.publicDB.add(nextOperation)
                } else {
                    print(fetchedPosts.description)
                    return completion(.success(fetchedPosts))
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.ckError(error)))
            }
            
            
        }
        
        publicDB.add(operation)
    }
    
    func fetchComments(for post: Post, completion: @escaping (Result<[Comment]?, PostError>) -> Void ) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentKeys.postReference, postReference)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate2])
        let query = CKQuery(recordType: CommentKeys.typeKey, predicate: compoundPredicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedComments: [Comment] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                if let comment = Comment(ckRecord: record) {
                    fetchedComments.append(comment)
                } else {
                    return completion(.failure(.noComment))
                }
            case .failure(let error):
                return completion(.failure(.ckError(error)))
            }
        }
        
        operation.queryResultBlock = {result in
            switch result{
            case .success(let cursor):
                if let cursor = cursor {
                    let nextOperation = CKQueryOperation(cursor: cursor)
                    nextOperation.queryResultBlock = operation.queryResultBlock
                    nextOperation.recordMatchedBlock = operation.recordMatchedBlock
                    nextOperation.qualityOfService = .userInteractive
                    operation = nextOperation
                    self.publicDB.add(nextOperation)
                } else {
                    print(fetchedComments.description)
                    return completion(.success(fetchedComments))
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(.failure(.ckError(error)))
            }
        }
        publicDB.add(operation)
    }
    
    func modifyCommentCount(post: Post, completion:  ((Bool) -> Void)?) {
        post.commentCount = post.comments.count
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        
        modifyOperation.savePolicy = .changedKeys
        
        modifyOperation.modifyRecordsResultBlock = { result in
            switch result {
            case .success():
                completion?(true)
                return
            case .failure(let error):
                print(error)
                completion?(true)
                return
            }
        }
        self.publicDB.add(modifyOperation)
    }
    
    
}


//func fetchWorkout(completion: @escaping (Result<[Workout]?, WorkoutError>) -> Void) {
//
//     let predicate = NSPredicate(value: true)
//
//     let query = CKQuery(recordType: Constants.workoutKey, predicate: predicate)
//
//     var operation = CKQueryOperation(query: query)
//
//     var fetchedWorkouts: [Workout] = []
//
//     operation.recordMatchedBlock = { (_, result) in
//
//         switch result {
//
//         case .success(let record):
//             guard let fetchedExercise = Workout(ckRecord: record) else {
//                 return completion(.failure(.noRecord))
//             }
//             fetchedWorkouts.append(fetchedExercise)
//
//
//         case .failure(let error):
//             print(error.localizedDescription)
//             return completion(.failure(.ckError(error)))
//         }
//         print("Inside operation.recordMatchBlock Switch")
//     }
//
//     // look for records that match query
//     operation.queryResultBlock = { result in
//
//         switch result {
//
//         case .success(let cursor):
//             if let cursor = cursor {
//                 let nextOperation = CKQueryOperation(cursor: cursor)
//
//                 nextOperation.queryResultBlock = operation.queryResultBlock
//
//                 nextOperation.recordMatchedBlock = operation.recordMatchedBlock
//
//                 nextOperation.qualityOfService = .userInteractive
//
//                 operation = nextOperation
//
//                 self.publicDB.add(nextOperation)
//             } else {
//
//                 print(fetchedWorkouts.description)
//                 return completion(.success(fetchedWorkouts))
//             }
//
//         case .failure(let error):
//             print(error.localizedDescription)
//             return completion(.failure(.ckError(error)))
//         }
//         print("Inside operation query block switch")
//     }
//     publicDB.add(operation)
// }
