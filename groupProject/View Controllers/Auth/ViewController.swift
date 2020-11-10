//
//  ViewController.swift
//  groupProject
//
//  Created by scott ritchie on 2020-03-11.
//  Copyright © 2020 Scott Ritchie. All rights reserved.
// Purpose: Entry Point of App Showing Button to Log In or Sign Up

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func unwindToHomeVC(sender : UIStoryboardSegue)
    {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //call method to style elements
        styleElements()
        
        //If segue'd from Sign Out Tab Bar Item, Therefore hide relationship to Tab Bar Controller
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //function that calls the utiltilities class to style the elements
    func styleElements()
    {
        
        
        //style the elements
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            
            do{
                try Auth.auth().signOut()
                //performSegue(withIdentifier: "signOut", sender: nil)
                
                let mainDelegate = UIApplication.shared.delegate as? AppDelegate
                mainDelegate?.currentUserID = ""
                print("Signed out success")
            } catch let err {
                print(err)
            }
            
            
        } else {
            // No user is signed in.
            // ...
        }
    }

}
