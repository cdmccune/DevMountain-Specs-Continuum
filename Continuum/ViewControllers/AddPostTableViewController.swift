//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/14/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit
import PhotosUI

class AddPostTableViewController: UITableViewController {
    
    //MARK: - Properties
    
  
    @IBOutlet var captionLabel: UITextField!
    
    var selectedImage: UIImage?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selectedImage = nil
        captionLabel.text = ""
    }
    
    //MARK: - Helper Functions
    
//    func presentPhotoPicker() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//
//        let alert = UIAlertController(title: "Add Photo", message: nil, preferredStyle: .actionSheet)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        alert.addAction(cancelAction)
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) in
//
//                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
//
//                self.present(imagePickerController, animated: true, completion: nil)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
//            self.presentPHPicker()
//        }))
//
//        present(alert, animated: true)
//    }
//
//    func presentPHPicker() {
//        var configuration = PHPickerConfiguration()
//        configuration.filter = PHPickerFilter.images
//        configuration.selectionLimit = 1
//
//        let picker = PHPickerViewController(configuration: configuration)
//        picker.delegate = self
//        self.present(picker, animated: true)
//    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = selectedImage,
              let caption = captionLabel.text,
              caption != "" else {return}
        PostController.shared
            .createPostWith(image: image, caption: caption) { _ in
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
    
    //MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImagePicker",
           let destination = segue.destination as? PhotoSelectorViewController{
            destination.delegate = self
        }
        
        
    }
    
    
    

}

extension AddPostTableViewController: PhotoSelectorViewControllerDelegate {
    func photoSelectorViewControllerSelected(image: UIImage) {
        selectedImage = image
    }
    
    
}

//extension AddPostTableViewController: UIImagePickerControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//
//        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//
//            selectImageButton.setTitle("", for: .normal)
//            postImage.image = photo
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//}
//
//extension AddPostTableViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//
//        dismiss(animated: true)
//
//
//        for result in results {
//            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//
//                if let image = image as? UIImage {
//                    DispatchQueue.main.async {
//                        self.postImage.image = image
//                        self.selectImageButton.setTitle("", for: .normal)
//                    }
//                }
//            }
//        }
//
//
//
//    }
//}
