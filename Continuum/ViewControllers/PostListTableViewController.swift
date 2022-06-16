//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    @IBOutlet var searchBar: UISearchBar!
    var resultsArray: [SearchableRecord] = []
    var isSearching = false
    var dataSource: [SearchableRecord] {
        return isSearching ? resultsArray : PostController.shared.posts
    }
    

    //MARK: - Lifecycles
    
    override func viewWillAppear(_ animated: Bool) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        pullPostsFromICloud()

    }
    
    //MARK: - Helper Functions
    
    func pullPostsFromICloud() {
        PostController.shared.fetchPosts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    if let posts = posts {
                        PostController.shared.posts = posts
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        
        cell.post = dataSource[indexPath.row] as? Post

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
    

} //End of Class

extension PostListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            resultsArray = PostController.shared.posts.filter({ post in
                post.matches(searchTerm: searchText)
            })
            tableView.reloadData()
        } else {
            resultsArray = PostController.shared.posts
            tableView.reloadData()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
    }
}
