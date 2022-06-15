//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    //MARK: - Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        print(PostController.shared.posts.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.shared.posts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        
        cell.post = PostController.shared.posts[indexPath.row]

        return cell
    }


 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail",
           let destinationVC = segue.destination as? PostDetailTableViewController,
           let index = tableView.indexPathForSelectedRow {
            destinationVC.post = PostController.shared.posts[index.row]
        }
    }
    

}
