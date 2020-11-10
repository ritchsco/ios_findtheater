//
//  HomeViewController.swift
//  MovieNight
//
//  Created by Shannon Lim on 2020-03-20
//
//  Purpose of class: Display the movie objects from TMDb calls in Featured Cell in a Collection View updated by with Segmented Controls

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //Instatiate the class with methods for fetching movies from TMBd API
    let movieData = MovieDetailsJsonParser()
    
    @IBOutlet var sgMovieCategory : UISegmentedControl!
    @IBOutlet weak var collectionView1 : UICollectionView!
    let reuseIdentifier = "featuredCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAPI()
        
        /////// GET CURRENT USER FROM FIREBASE STUFF /////////////
        //put after login page on homepage or favourites page view controller
        //FireBase get currently signed in user
        //https://firebase.google.com/docs/auth/ios/manage-users#get_a_users_profile
        let user = Auth.auth().currentUser
            if let user = user {
                
                let mainDelegate = UIApplication.shared.delegate as? AppDelegate
                // The user's ID, unique to the Firebase project.
                // Do NOT use this value to authenticate with your backend server,
                // if you have one. Use getTokenWithCompletion:completion: instead.
                let uid = user.uid
                mainDelegate?.currentUserID = uid
                
                print("Current User Id: \(user.uid)")
            }
        //store uid in appdelegate
       
    }
    
    //Get user selected segmented control and send HTTP GET Request on appropriate TMDb url
    func updateAPI(){
        
        let diff = sgMovieCategory.selectedSegmentIndex // selectedSegmented index part o UISegmentedCOntrol
        
        if diff == 0 {
            
            movieData.getDataFromJson(apiChoice: 0)
            
        }else if diff == 1 {
            
            movieData.getDataFromJson(apiChoice: 1)
            
        }else{
            
            movieData.getDataFromJson(apiChoice: 2)
        }
        
    }
    
    //Listen for segmented control change so you can change TMDb API Url Request and fetch selected array of movies
    @IBAction func segmentValueChanged(sender:UISegmentedControl){
        
        //Clear the array
        movieData.movies.removeAll()
        
        updateAPI()
        
        // Based on changed array of movies data reload Collection View
        collectionView1.reloadData()
        
        collectionView1.reloadItems(at: collectionView1.indexPathsForVisibleItems)
        
    }
    // Method of Protocols UICollectionViewDataSource and UICollectionViewDelegate required to implement for look and feel
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 50
    }
    // Method of Protocols UICollectionViewDataSource and UICollectionViewDelegate required to implement for look and feel
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat{
        return 50
    }
    // Method of Protocol UICollectionViewDataSource and UICollectionViewDelegate required to implement for look and feel
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
    }
    
    // Method of Protocol UICollectionViewDataSource and UICollectionViewDelegate required to implement
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Method of Protocol UICollectionViewDataSource and UICollectionViewDelegate required to implement
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView1{
            return movieData.movies.count
        }
        
        return 0
    }
    //Provide content to the Outlets from the Movie Object array for each custom cell of type FeaturedCollectionCell.swift
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == self.collectionView1){
            let cell : FeaturedCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! FeaturedCollectionViewCell
            
            //Poster field from API JSON could be empty
            if(movieData.movies[indexPath.row].poster == "unavailable"){
                
                        cell.featuredImage.image = UIImage(named: "poster-placeholder.png")
                
            }else{
                //display an image from a remote url
                let imageURL = URL(string: movieData.movies[indexPath.row].poster)
                
                // just not to cause a deadlock in UI!
                DispatchQueue.global().async {
                    let imageData = try? Data(contentsOf: imageURL!)
                    
                    let image = UIImage(data: imageData!)
                    DispatchQueue.main.async {
                        
                        cell.featuredImage.image = image
                    
                    }
                }
            }

            cell.lblTitle.text = movieData.movies[indexPath.row].title
            
            cell.lblReleaseDate.text = movieData.movies[indexPath.row].releaseDate
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    //Before Segue to Individual Movie Details View page we need to save the Selected movie in the AppDelegate for sharing between objects
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mainDelegate = UIApplication.shared.delegate as? AppDelegate
        
        mainDelegate?.selectedMovie = movieData.movies[indexPath.row]
        
        performSegue(withIdentifier: "SegueToMovieDetails", sender: nil)
    }
    

    @IBAction func unwindToHomeVC(Sender: UIStoryboardSegue){
        
    }

}
