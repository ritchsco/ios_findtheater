//
//  Movie.swift
//  MovieNight
//
//  Created by Shannon Lim on 2020-03-19
//
//  Purpose: Model class with stores data to sent between the Controller and View

import Foundation // import to access NSObject

struct Movie {
    
    
    var mid : Int = 0 //mid is TMDB movie ID primary key
    var title : String = ""
    var poster : String = ""
    var voteAverage : NSNumber = 0.0
    var releaseDate : String = ""
    var overview : String = ""
}
