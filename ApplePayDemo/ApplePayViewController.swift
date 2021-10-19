//
//  ApplePayViewController.swift
//  ApplePayDemo
//
//  Created by Saish Chachad on 18/10/21.
//

import UIKit

final class ApplePayViewController: UIViewController {

    @IBOutlet weak var userIdentifierLabel: UILabel!
    @IBOutlet weak var givenNameLabel: UILabel!
    @IBOutlet weak var familyNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var userIdentifier: String?
    var fullName: PersonNameComponents?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdentifierLabel.text = userIdentifier ?? KeychainItem.currentUserIdentifier
        givenNameLabel.text = fullName?.givenName ?? ""
        familyNameLabel.text = fullName?.familyName ?? ""
        emailLabel.text = email ?? ""
    }
    
    @IBAction func signOutButtonPressed() {
        // For the purpose of this demo app, delete the user identifier that was previously stored in the keychain.
        KeychainItem.deleteUserIdentifierFromKeychain()
        
        // Clear the user interface.
        userIdentifierLabel.text = ""
        givenNameLabel.text = ""
        familyNameLabel.text = ""
        emailLabel.text = ""
        
        // Display the login controller again.
        DispatchQueue.main.async {
            print("Show login view")
            self.dismiss(animated: true, completion: nil)
        }
    }

}
