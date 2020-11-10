//
//  FavouritesTableViewController.swift
//  MovieNight
//
//  Created by Shannon Lim on 2020-04-11
//
//  Purpose: This file is for displaying the SQLITE Database Favourite in a Table View

import UIKit

class FavouritesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //This field has a method reloadData() which I need to call
    @IBOutlet var myTableView : UITableView!
    
    //Request access to the App Delegate singleton class
    let mainDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // check if the user is signed in
        if ( (mainDelegate?.currentUserID) != nil ){
         
            //select from favourite table of the database
            mainDelegate?.readDataFromDatabase()
        
        }else{
            print("no user is not logged in therefore no users favourites")
        }
    }
    
    //Purpose: Since database may have been changed, reload Sections and Rows of the table view
    override func viewWillAppear(_ animated: Bool) {
        if ( mainDelegate!.favouriteMovies.count > 0){
            myTableView.reloadData()
        }
        
    }
    
    // Method of UITableViewDataSource protocol required to implement
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mainDelegate!.favouriteMovies.count
    }
    // Method of UITableViewDataSource protocol required to implement
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    // Method of UITableViewDelegate protocol required to implement
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SiteCell ?? SiteCell(style: .default, reuseIdentifier: "cell")
        
        let rowNum = indexPath.row
        
        tableCell.primaryLabel.text = mainDelegate?.favouriteMovies[rowNum].title
        tableCell.secondaryLabel.text = mainDelegate?.favouriteMovies[rowNum].releaseDate
        
        //Check is image url was provided by The Movie Database TMDb API, since they don't provide a poster for every movie
        if(mainDelegate?.favouriteMovies[rowNum].poster == "unavailable"){
            
            tableCell.myImageView.image = UIImage(named: "poster-placeholder.png")
            
        }else{
            //Display an image from a remote url
            let imageURL = URL(string: (mainDelegate?.favouriteMovies[rowNum].poster)!)
            
            // just not to cause a deadlock in UI!
            DispatchQueue.global().async {
                let imageData = try? Data(contentsOf: imageURL!)
                
                let image = UIImage(data: imageData!)
                DispatchQueue.main.async {
                    
                    tableCell.myImageView.image = image
                    
                }
            }
        }
        
        
        tableCell.accessoryType = .disclosureIndicator
        
        return tableCell
        
    }
    
    //Purpose: Assisting method for allowing swiping right to delete
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Purpose: Method for swiping right to delete row from database
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCell.EditingStyle.delete){
            
            var selectedFav : Movie = self.mainDelegate!.favouriteMovies[indexPath.row]
            
            let returnCode = mainDelegate!.deleteFromDatabase(selectedMovieId: selectedFav.mid)
            
            var returnMSG = "Successfully deleted selected row in database."
            
            if(returnCode == false){
                returnMSG = "Failed to delete row in database."
            }
            
            print(returnMSG)
            
            // The following method calls animate swipe delete on the view
            
            mainDelegate!.favouriteMovies.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        mainDelegate?.selectedMovie = mainDelegate!.favouriteMovies[indexPath.row]
        
        performSegue(withIdentifier: "SegueToMovieDetails2", sender: nil)    }
    
    
    @IBAction func unwindToTableVC(Sender: UIStoryboardSegue){
  
    }

}
