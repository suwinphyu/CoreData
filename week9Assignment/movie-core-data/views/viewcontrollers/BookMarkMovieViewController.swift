//
//  BookMarkMovieViewController.swift
//  movie-core-data
//
//  Created by Su Win Phyu on 9/26/19.
//  Copyright © 2019 padc. All rights reserved.
//

import UIKit
import CoreData

class BookMarkMovieViewController: UIViewController {

    @IBOutlet weak var bookMarkCollectionView: UICollectionView!
    
    var fetchResultController : NSFetchedResultsController<BookMarkVO>!
    var bookMarkVO : BookMarkVO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initMovieListFetchRequestByBookMark()

    }
    
    fileprivate func initView() {
        bookMarkCollectionView.dataSource = self
        bookMarkCollectionView.delegate = self
        bookMarkCollectionView.backgroundColor = Theme.background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "BookMark"
    }
    
    fileprivate func initMovieListFetchRequestByBookMark(){
        let fetchRequest : NSFetchRequest<BookMarkVO> = BookMarkVO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil, cacheName: "")
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            if let result = fetchResultController.fetchedObjects {
                if result.isEmpty {
                    bookMarkCollectionView.reloadData()
                }
            }
            
        }catch {
            Dialog.showAlert(viewController: self, title: "Error", message: "Failed to fetch data from database")
            
        }
        
    }
   

}

extension BookMarkMovieViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieDetailsViewController = segue.destination as? MovieDetailsViewController {
            
            if let indexPaths = bookMarkCollectionView.indexPathsForSelectedItems, indexPaths.count > 0 {
                let selectedIndexPath = indexPaths[0]
                let movieId = Int(fetchResultController.object(at: selectedIndexPath).id)
                let movie = MovieVO.getMovieById(movieId: movieId)
                
                movieDetailsViewController.movieId = movieId
                
                self.navigationItem.title = movie?.original_title ?? ""
            }
            
        }
    }
}

extension BookMarkMovieViewController : UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultController.sections?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return fetchResultController.sections?[section].numberOfObjects ?? 0
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookMarkCollectionViewCell.identifier, for: indexPath) as? BookMarkCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movieByBookMark = fetchResultController.object(at: indexPath)
        let movie = MovieVO.getMovieById(movieId: Int(movieByBookMark.id))
        cell.data = movie
        return cell

       
    }
}

extension BookMarkMovieViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}

extension BookMarkMovieViewController : NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        bookMarkCollectionView.reloadData()
    }
}
