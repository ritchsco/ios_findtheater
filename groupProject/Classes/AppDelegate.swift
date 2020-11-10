//
//  AppDelegate.swift
//  groupProject
//
//  Created by scott ritchie on 2020-03-11.
//  Copyright © 2020 Scott Ritchie. All rights reserved.
//
//  Also Created by Shannon Lim on 2020-03-19
//
//  Purpose: Singleton class that is instantiated only once and is for sharing data between objects
//      This contains all the methods for SQLite database access such as database creation, select/read, insert and delete.

import UIKit
import Firebase
import SQLite3
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var databaseName: String? = "MyDatabase6.db"
    var databasePath: String?
    var favouriteMovies : [Movie] = []
    var currentUserID : String?
    
    // sharing data (from model selected movie object) between objects
    var selectedMovie: Movie = Movie()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //Find the Documents folder in iPhone
        
        let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDir = documentPaths[0]
        
        databasePath = documentsDir.appending("/" + databaseName!)
        
        checkAndCreateDatabase()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
        }
        
        return true
    }
    
    func checkAndCreateDatabase(){
        var success = false
        
        let fileManager = FileManager.default
        
        success = fileManager.fileExists(atPath: databasePath!)
        
        //if file exists then success is true return out of method
        if success{
            return
        }
        
        let databasePathFromApp = Bundle.main.resourcePath?.appending("/" + databaseName!)
        
        //copy item in app to item on phone
        try? fileManager.copyItem(atPath: databasePathFromApp!, toPath: databasePath!)
        
        return
    }
    
    //check first if currentuser == "" or null
    func readDataFromDatabase(){
        
        favouriteMovies.removeAll()
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(self.databasePath, &db) == SQLITE_OK {
            print("successfully opened connection to database at \(self.databasePath)")
            //malloc memory
            var queryStatement : OpaquePointer? = nil
            let queryStatementString : String = "select * from favourites where userID=?"
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
                
                let userid = currentUserID! as NSString
                
                sqlite3_bind_text(queryStatement, 1, userid.utf8String, -1, nil)
                
                var setMovieIds = Set<Int>()
                
                while(sqlite3_step(queryStatement) == SQLITE_ROW){
                    
                    let userId : Int = Int(sqlite3_column_int(queryStatement, 0))
                    let movieId : Int = Int(sqlite3_column_int(queryStatement, 2))
                    
                    setMovieIds.insert(movieId)
                    
                    print("query result: " + "\(userId) | \(movieId)")
                    
                }
                //free up malloc'd memory, flush data
                sqlite3_finalize(queryStatement)
                
                //Send set of Movie IDs to web API to get Movie Object Favourites Array
                favouriteMovies = MovieDetailsJsonParser().getDataFromJson(movieIDs: setMovieIds)
                
            }else{
                print("unable to prepare select statement")
            }
            sqlite3_close(db)
        }else{
            print("Database was unable to be opened")
        }
    }
    
    //Add to Favourites Table in SQLITE3
    func insertIntoDatabase(myMovie : Movie) -> Bool {
        var db: OpaquePointer? = nil
        var returnCode : Bool = true
        
        if sqlite3_open(self.databasePath, &db) ==  SQLITE_OK {
            
            var insertStatement : OpaquePointer? = nil
            let insertStatementString : String = "insert into favourites values(NULL, ?,?)"
            if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
                
                let uidStr = currentUserID! as NSString
                let midInt32 = Int32(myMovie.mid)
                
                sqlite3_bind_text(insertStatement, 1, uidStr.utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 2, midInt32)
                
                if sqlite3_step(insertStatement) == SQLITE_DONE{
                    let rowID = sqlite3_last_insert_rowid(db)
                    print("successfully insert row \(rowID)")
                }else{
                    print("could not insert row")
                    returnCode = false
                }
                sqlite3_finalize(insertStatement)
            }else{
                print("insert statement could not be prepared")
                returnCode = false
            }
            
            sqlite3_close(db)
        }
        
        return returnCode
        
    }
    
    //Delete from favourites table in SQLITE3
    func deleteFromDatabase(selectedMovieId: Int) -> Bool {
        var db: OpaquePointer? = nil
        var returnCode : Bool = true
        
        if sqlite3_open(self.databasePath, &db) ==  SQLITE_OK {
            
            var deleteStatement : OpaquePointer? = nil
            
            //"delete from users where id=?"
            var deleteStatementString : String = "delete from favourites where userID=? and movieId=?"
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
                
                
                let uidStr = currentUserID! as NSString
                let movieIdInt32 = Int32(selectedMovieId)
                
                sqlite3_bind_text(deleteStatement, 1, uidStr.utf8String, -1, nil)
                
                sqlite3_bind_int(deleteStatement, 2, movieIdInt32)
                
                if sqlite3_step(deleteStatement) == SQLITE_DONE{
                    
                    let rowsAffected = sqlite3_changes(db)
                    
                    print("successfully deleted \(rowsAffected) row(s)")
                    
                }else{
                    print("could not delete row")
                    returnCode = false
                }
                sqlite3_finalize(deleteStatement)
            }else{
                print("delete statement could not be prepared")
                returnCode = false
            }
            
            sqlite3_close(db)
        }
        
        return returnCode
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

