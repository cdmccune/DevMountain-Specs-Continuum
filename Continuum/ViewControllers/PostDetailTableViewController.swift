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

     
    }
    
    //MARK: - Helper Functions
    
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
        return cell
    }

    @IBAction func commentButtonTapped(_ sender: Any) {
        let alert = UIAlertController()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(OKAction)
        
        self.present(alert, animated: true)
    }
    

}
