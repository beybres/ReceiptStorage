//
//  ReceiptListViewController.swift
//  ReceiptStorage
//
//  Created by Beyhan Bresner on 21/03/19.
//  Copyright © 2019 Beyhan Bresner. All rights reserved.
//

import UIKit
import Firebase

class ReceiptListViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var receiptTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK:- Properties
    var receiptDatasource = [Receipt]()
    var backUpReceiptSource = [Receipt]()
    var selectedReceipt: Receipt?
    
    //MARK:- ViewController's LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if User.currentUser.isLoggedIn == false {
            StoryboardManager.segueToLogin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchReceiptsFromFirebase()
    }
    
    //MARK:- General Methods
    func fetchReceiptsFromFirebase() {
        self.receiptDatasource.removeAll()
        self.showActivityIndicatorView()
        let receiptsRef = Database.database().reference(withPath: "receipts").child("\(User.currentUser.id!)")
        receiptsRef.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.value != nil {
                var receipts: [Receipt] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                        let receipt = Receipt(snapshot: snapshot) {
                        receipts.append(receipt)
                    }
                }
                self.receiptDatasource = receipts
                self.backUpReceiptSource = receipts
                self.receiptTableView.reloadData()
                self.hideActivityIndicatorView()
            } else {
                self.hideActivityIndicatorView()
                self.showAlert(title: "Error!", message: "Please relead again!", button1Title: "OK", button1Handler: {})
            }
        })
    }
    
    func deleteReceiptFromFirebase(date: String) {
        self.showActivityIndicatorView()
        let storageRef = Storage.storage().reference().child("\(User.currentUser.id!)").child("\(date)")
        let receiptsRef = Database.database().reference(withPath: "receipts").child("\(User.currentUser.id!)").child("\(date)")
        
        storageRef.delete { error in
            if let error = error {
                self.showAlert(title: "Error!", message: error.localizedDescription, button1Title: "OK", button1Handler: {
                    self.hideActivityIndicatorView()
                })
                print(error)
            } else {
                receiptsRef.removeValue(completionBlock: { (error, ref) in
                    if let error = error {
                        self.showAlert(title: "Error!", message: error.localizedDescription, button1Title: "OK", button1Handler: {
                            self.hideActivityIndicatorView()
                        })
                        print(error)
                    } else {
                        self.fetchReceiptsFromFirebase()
                    }
                    
                })
            }
        }
    }
    
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

}

//MARK:- Button Actions
extension ReceiptListViewController {
    @IBAction func logoutButtonPressed() {
        do {
            try Auth.auth().signOut()
            User.currentUser.logOut()
            StoryboardManager.segueToLogin()
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func addButtonPressed() {
        self.selectedReceipt = nil
        self.performSegue(withIdentifier: "ListToAdd", sender: self)
    }
}


//MARK:- TableView Delegate and Datasource Methods
extension ReceiptListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.receiptDatasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = self.receiptDatasource[indexPath.row].name
        cell.textLabel?.font = UIFont(name: "Avenir-Book", size: 18.0)!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.receiptTableView.deselectRow(at: indexPath, animated: true)
        self.selectedReceipt = self.receiptDatasource[indexPath.row]
        self.performSegue(withIdentifier: "ListToAdd", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteReceiptFromFirebase(date: self.receiptDatasource[indexPath.row].date)
        }
        return [delete]
    }
}

//MARK:- Searchbar Delegate
extension ReceiptListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.receiptDatasource.removeAll()
            self.receiptDatasource = self.backUpReceiptSource
            self.receiptTableView.reloadData()
        }
        else {
            self.receiptDatasource.removeAll()
            self.receiptDatasource = self.backUpReceiptSource.filter {($0.name.lowercased().contains(searchText.lowercased()))}
            self.receiptTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}

//MARK:- Segue
extension ReceiptListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ListToAdd" {
            let destinationVC = segue.destination as! AddReceiptViewController
            destinationVC.selectedReceipt = self.selectedReceipt
        }
    }
}
