//
//  AddReceiptViewController.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 22/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

import UIKit
import Firebase

class AddReceiptViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var receiptImageView: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var receiptNameTextField: UITextField!
    @IBOutlet weak var addReceiptButton: UIButton!
    
    //MARK:- PRoperties
    var imagePicker = UIImagePickerController()
    let receiptRef = Database.database().reference(withPath: "receipts")
    var selectedReceipt: Receipt?
    
    
    //MARK:- ViewController's LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.selectedReceipt != nil {
            self.chooseImageButton.isHidden = true
            let url = URL(string: self.selectedReceipt!.receiptUrl)!
            do {
                let imageData = try Data(contentsOf: url)
                self.receiptImageView.image = UIImage(data: imageData)
            } catch let error {
                print(error)
            }
            self.receiptNameTextField.text = self.selectedReceipt!.name
            self.receiptNameTextField.isEnabled = false
            self.addReceiptButton.isHidden = true
            self.title = self.selectedReceipt!.date
        } else {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
            self.receiptImageView.addGestureRecognizer(tapGesture)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            self.title = "Add Receipt"
        }
    }
    
    //MARK:- General Methods
    func showAlert(title:String, message:String, button1Title: String?, button1Handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: button1Title, style: .cancel, handler: { (action) in
            button1Handler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showActivityIndicatorView() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicatorView() {
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= 150
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += 150
        }
    }
    
    func validateInputs() -> Bool {
        if self.receiptImageView.image == nil {
            self.showAlert(title: "Error!", message: "Please select receipt image.", button1Title: "OK", button1Handler: {})
            return false
        } else if self.receiptNameTextField.text == "" {
            self.showAlert(title: "Error!", message: "Please enter receipt name.", button1Title: "OK", button1Handler: {})
            return false
        } else {
            return true
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Error!", message: "Your device don't have camera!", button1Title: "OK", button1Handler: {})
        }
    }
    
    func openGallary() {
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func convertDateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    @objc func showImagePicker() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera()
        }
        let gallaryAction = UIAlertAction(title: "Choose from Photo Library", style: .default) { (action) in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        imagePicker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadReceiptPicture(image: UIImage, completion: @escaping ((_ url: URL?, _ date: String) -> ())) {
        let currentDate = self.convertDateToString(date: Date())
        let storageRef = Storage.storage().reference().child("\(User.currentUser.id!)").child("\(currentDate)")
        let imgData = image.jpegData(compressionQuality: 0.5)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil{
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url, currentDate)
                })
            } else {
                print(error!)
                print("error in save image")
                completion(nil, currentDate)
            }
        }
    }
    
    func saveReceiptOnFirebase(receiptInfo: [String: Any], currentDate: String, completion: @escaping ((Bool) -> ())) {
        let myUserRef = receiptRef.child(User.currentUser.id!).child("\(currentDate)")
        myUserRef.updateChildValues(receiptInfo, withCompletionBlock: { (error, ref) in
            if error != nil {
                print("receipt information doesn't saved on firebase!")
                completion(false)
            } else {
                completion(true)
            }
        })
    }

}

//MARK:- Button Actions
extension AddReceiptViewController {
    @IBAction func addReceiptButtonPressed() {
        if self.validateInputs() {
            self.showActivityIndicatorView()
            self.uploadReceiptPicture(image: self.receiptImageView.image!) { (url, currentDate) in
                var receiptDataDic = [String: Any]()
                receiptDataDic["name"] = self.receiptNameTextField.text
                receiptDataDic["imageUrl"] = url!.absoluteString
                receiptDataDic["date"] = currentDate
                self.saveReceiptOnFirebase(receiptInfo: receiptDataDic, currentDate: currentDate, completion: { (success) in
                    if success == true {
                        self.hideActivityIndicatorView()
                        self.showAlert(title: "Done!", message: "Receipt saved successfully.", button1Title: "OK", button1Handler: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    } else {
                        self.hideActivityIndicatorView()
                        self.showAlert(title: "Error!", message: "Receipt can not be saved. Please try again later!", button1Title: "OK", button1Handler: {
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }
        }
    }
    
    @IBAction func chooseImageButtonPressed() {
        self.showImagePicker()
    }
}

//MARK:- Textfield Delegate Methods
extension AddReceiptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

//MARK:- UIImage PickerController Delegate
extension AddReceiptViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imagePicker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.receiptImageView.image = image
        self.chooseImageButton.isHidden = true
    }
}
