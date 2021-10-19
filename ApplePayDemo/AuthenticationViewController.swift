//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Saish Chachad on 06/10/21.
//

import UIKit
import AuthenticationServices


final class AuthenticationViewController: UIViewController {
    
    let authorizationButton = ASAuthorizationAppleIDButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       setUpSignInAppleButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authorizationButton.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        authorizationButton.center = view.center
        
        performExistingAccountSetupFlows()
    }
}

extension AuthenticationViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    // ASAuthorizationControllerDelegate function for authorization failed
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleCredentials as ASAuthorizationAppleIDCredential:
            let appleId = appleCredentials.user
            let firstName = appleCredentials.fullName?.givenName ?? ""
            let lastName = appleCredentials.fullName?.familyName ?? ""
            let email = appleCredentials.email ?? ""
            print("appleId:\(appleId), firstName:\(firstName), lastName:\(lastName), email:\(email)")
            
            self.saveUserInKeychain(appleId)
            
            self.showApplePayViewController(userIdentifier: appleId,
                                            fullName: appleCredentials.fullName,
                                            email: appleCredentials.email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("User:\(username), Password:\(password)")
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
        
        default:
            break
        }
    }
}

private extension AuthenticationViewController {
    
    func setUpSignInAppleButton() {
        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
        authorizationButton.cornerRadius = 10
        view.addSubview(authorizationButton)
    }
    
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // - Tag: perform_appleid_password_request
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.saish.applePay.demo", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    func showApplePayViewController(userIdentifier: String,
                                    fullName: PersonNameComponents?,
                                    email: String?) {

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let nextVC = storyBoard.instantiateViewController(withIdentifier: "ApplePayViewController") as? ApplePayViewController else { return }
        nextVC.userIdentifier = userIdentifier
        nextVC.fullName = fullName
        nextVC.email = email
        self.present(nextVC, animated:true, completion:nil)
        
    }
    
    func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
