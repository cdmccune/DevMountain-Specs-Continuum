//
//  PhotoSelectorViewController.swift
//  Continuum
//
//  Created by Curt McCune on 6/15/22.
//  Copyright © 2022 trevorAdcock. All rights reserved.
//

import UIKit
import PhotosUI

protocol PhotoSelectorViewControllerDelegate: AnyObject {
    func photoSelectorViewControllerSelected(image: UIImage)
}

class PhotoSelectorViewController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: PhotoSelectorViewControllerDelegate?
    
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var selectImageButton: UIButton!
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postImage.image = nil
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        postImage.image = nil
        selectImageButton.setTitle("Select Image", for: .normal)
    }
    
    //MARK: - Helper Functions
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        presentPhotoPicker()
    }
    
    
    func presentPhotoPicker() {
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
        
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            self.presentPHPicker()
        }))

        present(alert, animated: true)
    }
    
    func presentPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }



}

extension PhotoSelectorViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let photo = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            selectImageButton.setTitle("", for: .normal)
            postImage.image = photo
            delegate?.photoSelectorViewControllerSelected(image: photo)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PhotoSelectorViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true)
        
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.postImage.image = image
                        self.selectImageButton.setTitle("", for: .normal)
                    }
                    self.delegate?.photoSelectorViewControllerSelected(image: image)
                }
            }
        }
        
        
        
    }
}
