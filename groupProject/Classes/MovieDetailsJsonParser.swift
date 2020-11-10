//
//  MovieDetails.swift
//  MovieNight
//
//  Created by Shannon Lim on 2020-03-19.
//
//  Purpose send HTTP GET Request to TMDb API to fetch JSON containing movie details from the TMDb server

import UIKit
import Foundation // needed to access NSObject

class MovieDetailsJsonParser: NSObject {
    
    //Array of movies objects from parsed Json into movie objects
    var movies: [Movie] = []
    
    var mid : Int = 0
    var title : String = ""
    var fullPosterPath : String = ""
    var voteAverage : NSNumber = 0.0
    var releaseDate : String = ""
    var overview : String = ""
    
    // apiLink[0] is web API url for Upcoming movies
    // apiLink[1] is web API url for Now Playing movies
    // apiLink[2] is web API url for Top Rated movies
    
    let apiLink : [String] = ["https://api.themoviedb.org/3/movie/upcoming?api_key=64aee71233303f691dfcb9185c3fd008&language=en-US&page=1&region=US","https://api.themoviedb.org/3/movie/now_playing?api_key=64aee71233303f691dfcb9185c3fd008&language=en-US&region=CA","https://api.themoviedb.org/3/movie/top_rated?api_key=64aee71233303f691dfcb9185c3fd008&language=en-US&page=1&region=CA"]
    
    //Receives Segmented index choice of for API url and Parses JSON response
    //JSON format in swift is interpreted as either NSDictionary indicated by {} , or NSArray indicated by []
    func getDataFromJson(apiChoice: Int){
        if let url = NSURL(string: apiLink[apiChoice]){
            
            if let data = NSData(contentsOf: url as URL){
                do{
                    let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    let rootDictionary = parsed as? NSDictionary
                    
                    //access the dictionary value with key "results"
                    //type cast value of "results" into NS Array
                    let arrayOfMovieDictionaries = rootDictionary?["results"] as? NSArray
                    
                    //loop through the array and instantiate movie object and store into movies array
                    for movie in arrayOfMovieDictionaries! {
                        
                        let movieDict = movie as? NSDictionary
                        
                        
                        mid = (movieDict?["id"] as? Int)!
                        
                        
                        title = (movieDict?["title"] as? String)!
                        
                        if let posterPath = movieDict?["poster_path"] as? String {
                            // obj is a string . Do something with string
                            fullPosterPath="https://image.tmdb.org/t/p/w500"+posterPath
                        }
                        else {
                            // obj is not a string e.g. nil therefore use placeholder
                            
                            fullPosterPath="unavailable"
                        }
                        
                        voteAverage = (movieDict!["vote_average"] as? NSNumber)!
                        
                        releaseDate = (movieDict?["release_date"] as? String)!
                        overview = (movieDict?["overview"] as? String)!
                        
                        //instantiate movie object with movie details
                        
                        let movie = Movie(mid: mid, title: title, poster: fullPosterPath, voteAverage: voteAverage, releaseDate: releaseDate, overview: overview)
                        
                        //add to array of movies objects
                        movies.append(movie)
                        
                    }
                }
                catch let error as NSError{
                    title = "A JSON parsing error has occurred"
                    fullPosterPath = error.description
                }
            }
            
        }
    }
    
    //clear movies array prior to calling this function?
    //called by favourite table view controller once read database favourite table provides a set of favorite movie ids. This method receives Set of Movie IDs and calls the API to get movie JSON and parses to movie instances. THe method returns to AppDelegate an the Array of Movies Objects (favourites only)
    func getDataFromJson(movieIDs: Set<Int>) -> [Movie]{
        
        movieIDs.forEach { movieID in
            
            var getMovieApiLink : String = "https://api.themoviedb.org/3/movie/\(movieID)?api_key=64aee71233303f691dfcb9185c3fd008&language=en-US"
            
            if let url = NSURL(string: getMovieApiLink){
                
                if let data = NSData(contentsOf: url as URL){
                    do{
                        let parsed = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments)
                        
                        let rootDictionary = parsed as? NSDictionary
                        
                        mid = (rootDictionary?["id"] as? Int)!
                        
                        title = (rootDictionary?["title"] as? String)!
                        
                        if let posterPath = rootDictionary?["poster_path"] as? String {
                            // obj is a string . Do something with string
                            fullPosterPath="https://image.tmdb.org/t/p/w500"+posterPath
                        }
                        else {
                            // obj is not a string e.g. nil therefore use placeholder
                            
                            fullPosterPath="unavailable"
                        }
                        
                        voteAverage = (rootDictionary!["vote_average"] as? NSNumber)!
                        
                        releaseDate = (rootDictionary?["release_date"] as? String)!
                        overview = (rootDictionary?["overview"] as? String)!
                        
                        //instantiate movie object with movie details
                        let movie = Movie(mid: mid, title: title, poster: fullPosterPath, voteAverage: voteAverage, releaseDate: releaseDate, overview: overview)
                        
                        //add to array of movies objects
                        movies.append(movie)
                        
                    }
                    catch let error as NSError{
                        title = "A JSON parsing error has occurred"
                        fullPosterPath = error.description
                    }
                }
            }
        }
        
        return movies
    }
    
}


