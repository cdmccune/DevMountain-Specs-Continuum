//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var commentButton: UIButton!
    
    
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateComments()
    }
    
    //MARK: - Helper Functions
    
    func updateComments() {
        guard let post = post else {return}

        PostController.shared.fetchComments(for: post) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let comments):
                    if let comments = comments {
                        post.comments = comments
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func updateViews() {
        guard let post = post else {return}
       
        postImageView.image = post.photo
        tableView.reloadData()
      
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        
        
        var content = cell.defaultContentConfiguration()
        
        content.text = comment?.text
        let date = comment?.timestamp ?? Date()
        content.secondaryText = DateForm.dateFormatter.string(from: date)
        cell.contentConfiguration = content
        return cell
    }

    @IBAction func commentButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add Your Comment", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let textField = alert.textFields?[0] else {return}
            if let comment = textField.text, comment != "", let post = self.post {
                PostController.shared.addComment(comment: comment, post: post) { _ in return}
                self.tableView.reloadData()
            }
        }
        alert.addTextField { textField in
            textField.placeholder = "Your comment..."
        }
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        
        self.present(alert, animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post else {return}

        if let photo = post.photo {
            let activityController = UIActivityViewController(activityItems: [photo, post.caption], applicationActivities: nil)
            present(activityController, animated: true)
        }
    }
    
    

}
