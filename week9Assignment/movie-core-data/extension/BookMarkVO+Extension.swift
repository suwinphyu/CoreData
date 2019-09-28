//
//  BookMarkVO+Extension.swift
//  movie-core-data
//
//  Created by Su Win Phyu on 9/28/19.
//  Copyright © 2019 padc. All rights reserved.
//

import Foundation
import CoreData

extension BookMarkVO{
    
    static func getFetchRequest() -> NSFetchRequest<BookMarkVO> {
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
    
    static func getMoviesByBookmarkFetchRequest(bookmark  : BookMarkVO) -> NSFetchRequest<MovieVO> {
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let predicate = NSPredicate(format: "id == %id", bookmark)
        fetchRequest.predicate = predicate
        return fetchRequest as! NSFetchRequest<MovieVO>
    }
    
    static func getMoviesByBookMark(bookmark  : BookMarkVO) -> [MovieVO]? {
        let fetchRequest = getMoviesByBookmarkFetchRequest(bookmark : bookmark)
        
        do {
            let data = try CoreDataStack.shared.viewContext.fetch(fetchRequest)
            if data.isEmpty {
                return nil
            }
            return data
        } catch {
            print("failed to fetch movie ?? ","): \(error.localizedDescription)")
            return nil
        }
    }
    
    static func saveBookMarkVO(movieId : Int, context : NSManagedObjectContext){
            
            let bookmark = BookMarkVO(context: context)
            bookmark.id = Int32(movieId)
   
            do{
                try context.save()
            }catch{
                print("error")
            }
        }
    
    static func deleteBookMarkVO(movieId : Int , context : NSManagedObjectContext){
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let predicate = NSPredicate(format: "id == %id", movieId)
        fetchRequest.predicate = predicate
        do {
            let results = try context.fetch(fetchRequest)
          
                let objectToDelete = results[0] as NSManagedObject
                context.delete(objectToDelete)
            
            do {
                try context.save()
            } catch  {
                fatalError("Failed to save")
            }
        } catch {
            fatalError("Failed to delete")
        }
    }
    
    static func isSelectBookMark(movieId : Int) -> Bool {
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let predicate = NSPredicate(format: "id == %d", movieId)
        fetchRequest.predicate = predicate
        do {
            let data = try CoreDataStack.shared.viewContext.fetch(fetchRequest)
            print("Bookmarked movie",data)
            if data.isEmpty{
                return false
            }
            return true
        } catch {
            print("Failed to fetch BookMarked Movie with id \(movieId): \(error.localizedDescription)")
            return false
        }

    }

    
}
