//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        Message (sender: "test@test.com", body: "Yo Wassup?"),
        Message (sender: "test1@test.com", body: "All good, sup?"),
        Message (sender: "test@test.com", body: "All cool")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView.delegate = self
        tableView.dataSource = self
        
        // App Name
        title = K.appName
        
        // Hide back button
        navigationItem.hidesBackButton = true
        
        // register custom message component
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        // load mesages from firebase
        loadMessages()
    }
    
    func loadMessages () {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { querySnaphot, error in
                self.messages = []
                
                if let e = error {
                    print ("There was an error while trying to load messages :  \(e)")
                } else {
                    for document in querySnaphot!.documents {
                        let data = document.data()
                        if let sender = data[K.FStore.senderField] as? String, let body = data[K.FStore.bodyField] as? String {
                            self.messages.append(Message (sender: sender, body: body))
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.senderField: messageSender,
                K.FStore.bodyField : messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                    if let e = error {
                        print ("There was an error while trying to add data to db : \(e)")
                    } else {
                        print ("Successfully saved the data")
                        DispatchQueue.main.async {
                            self.messageTextfield.text = ""
                        }
                    }
                }
        }
    }
    
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            
            // Go To Welcome Screen
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: ", signOutError)
        }
    }
}

// Protocol responsible to populate data
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath[1]]
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        return cell
    }
}

// Lets us control the selected row
//extension ChatViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print ("Row selected : \(indexPath[1])")
//    }
//}
