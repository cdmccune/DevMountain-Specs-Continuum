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
import UserNotifications

class PostController {
    
    //MARK: - Properties
    
    static var shared = PostController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    var posts: [Post] = []
    
    private init() {
        subscribeToNewPosts(completion: nil)
    }
    
    
    //MARK: - iCloud Crud Functions
    
    func addComment(comment: String, post: Post, completion: @escaping (Result<Comment, PostError>) -> Void) {
        
        
        let postReference = CKRecord.Reference(recordID: post.recordID, action: .none)
        let comment = Comment(text: comment, postReference: postReference)
        let record = CKRecord(comment: comment)
        
        post.comments.insert(comment, at: 0)
        post.commentCount = post.comments.count
        
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
                    fetchedPosts.insert(post, at: 0)
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
//        let commentIDs = post.comments.compactMap({$0.recordID})
//        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate,predicate2])
//        let query = CKQuery(recordType: CommentKeys.typeKey, predicate: compoundPredicate)
        let query = CKQuery(recordType: CommentKeys.typeKey, predicate: predicate)
        var operation = CKQueryOperation(query: query)
        
        var fetchedComments: [Comment] = []
        
        operation.recordMatchedBlock = { (_, result) in
            switch result {
            case .success(let record):
                if let comment = Comment(ckRecord: record) {
                    fetchedComments.insert(comment, at: 0)
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
    
    func updateCommentsOnPost(post: Post, comments: [Comment]) {
        guard let index = posts.firstIndex(of: post) else {return}
        posts[index].comments = comments
    }
    
    //MARK: - Subscription Functions
    
    func subscribeToNewPosts(completion: ((Bool, Error?) -> Void)?) {
//        guard !UserDefaults.standard.bool(forKey: "didCreateQuerySubscription")
//            else { return }
        
        let predicate = NSPredicate(value: true)
        
        let subscription = CKQuerySubscription(recordType: PostStrings.typeKey,
                                               predicate: predicate,
                                               subscriptionID: "Physical device",
                                               options: .firesOnRecordCreation)
        
        let notifcationInfo = CKSubscription.NotificationInfo()
        notifcationInfo.alertBody = "New post added to Continuum"
        
        notifcationInfo.shouldBadge = true
        notifcationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifcationInfo
        
        publicDB.save(subscription) { _, error in
            if let error = error {
                print("error creating subscription: \(error)")
                completion?(false, error)
                return
            }
            completion?(true, nil)
            print("success")
            return
        }
        
//        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
//                                                       subscriptionIDsToDelete: nil)
//
//        operation.modifySubscriptionsResultBlock = {result in
//            switch result {
//            case .success():
//                print("success")
////                UserDefaults.standard.setValue(true, forKey: "didCreateQuerySubscription")
//            case .failure(let error):
//                print("error creating a subscription for new posts: \(error)")
//                return
//            }
//        }
//
//        operation.qualityOfService = .userInteractive
//        publicDB.add(operation)
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentKeys.postReference, postReference)
        
        let subscription = CKQuerySubscription(recordType: CommentKeys.typeKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: .firesOnRecordCreation)

        
        let notifcationInfo = CKSubscription.NotificationInfo()
        notifcationInfo.alertBody = "New post added to Continuum"
        
        notifcationInfo.shouldBadge = true
        notifcationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notifcationInfo
        
        publicDB.save(subscription) { _, error in
            if let error = error {
                print(error)
                completion?(false, error)
                return
            }
            completion?(true, nil)
            return
        }
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        publicDB.delete(withSubscriptionID: post.recordID.recordName) { _, error in
            if let error = error {
                print(error)
                completion?(false, error)
                return
            }
            completion?(true, nil)
            return
        }
    }
    
    func checkSubscription(to post: Post, completion: ((Bool)->Void)?) {
        publicDB.fetch(withSubscriptionID: post.recordID.recordName) { subscription, error in
            if error != nil {
//                print(error)
                completion?(false)
                return
            }
            
            subscription != nil ? completion?(true): completion?(false)
            return
               
        }
    }
    
    func toggleSubscriptionTo(commentForPost post: Post, completion: ((Bool, Error?) -> Void)?) {
        checkSubscription(to: post) { doesExist in
            
            print("Subscription exists: \(doesExist)")
            
            if !doesExist {
                
                self.addSubscriptionTo(commentsForPost: post) { success, error in
                    if let error = error, !success {
                        print("error subscribing to comments for post \(post.caption) ----  \(error)")
                        completion?(false, error)
                        return
                    }
                    
                    if success {
                        print("success subscribing to post with caption: \(post.caption)")
                        completion?(true, nil)
                        return
                    } else{
                        print("some other error")
                        completion?(false, nil)
                    }
                    
                   
                }
            } else {
                self.removeSubscriptionTo(commentsForPost: post) { success, error in
                    if success {
                        print("removed subscription for post with caption: \(post.caption)")
                        completion?(true, nil)
                        return
                    } else {
                        print("error removing subsciption for post with caption \(post.caption)")
                        completion?(false, error)
                        return
                    }
                }
            }
            
        }
        
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
