//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var captionLabel: UITextField!
    
    var selectedImage: UIImage?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectImageButton.setTitle("Select Image", for: .normal)
        postImage.image = nil
        selectedImage = nil
        captionLabel.text = ""
    }
    
    //MARK: - Helper Functions
    
    func presentImagePickerActionSheet() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
                
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (_) in
                
                imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
                
                self.present(imagePickerController, animated: true, completion: nil)
            }))
        }
        
        present(alert, animated: true)
    }
    
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        presentImagePickerActionSheet()
        selectImageButton.setTitle("", for: .normal)
//        postImage.image = UIImage(named: "spaceEmptyState")
//        selectImageButton.setTitle("", for: .normal)
//        selectedImage = UIImage(named: "spaceEmptySpace")
    }
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = postImage.image,
              let caption = captionLabel.text,
              caption != "" else {return}
        PostController.shared
            .createPostWith(image: image, caption: caption) { _ in
                print("hi")
            }
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func editingEnded(_ sender: Any) {
        captionLabel.resignFirstResponder()
    }
    
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddPostTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            selectImageButton.setTitle("", for: .normal)
            postImage.image = photo
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
