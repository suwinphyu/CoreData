//
//  ViewController.swift
//  movie-core-data
//
//  Created by Thet Htun on 9/17/19.
//  Copyright © 2019 padc. All rights reserved.
//

import UIKit
import CoreData

class MovieListViewController: UIViewController {
    
    @IBOutlet weak var collectionViewMovieList : UICollectionView!
    
    var fetchRequestController : NSFetchedResultsController<MovieVO>!
    var movies = [MovieInfoResponse]()
    // var movieVO = [MovieVO]()
    let TAG : String = "MovieListViewController"
    
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:#selector(handleRefresh(_:)),for: .valueChanged)
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.fetchTopRatedMovies()
    }
    
    private func initView() {
        collectionViewMovieList.dataSource = self
        collectionViewMovieList.delegate = self
        collectionViewMovieList.backgroundColor = Theme.background
        
        //Add RefreshControl
        self.collectionViewMovieList.addSubview(refreshControl)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
        //Remove all cached data in URL Response
        URLCache.shared.removeAllCachedResponses()

        initGenreListFetchRequest()

        initMovieListFetchRequest()
        
    }
    
    fileprivate func initGenreListFetchRequest() {
        //TODO : Fetch Genre List
        let fetchRequest : NSFetchRequest<MovieGenreVO> = MovieGenreVO.fetchRequest()

        do {
              let genres = try CoreDataStack.shared.viewContext.fetch(fetchRequest)
                if genres.isEmpty{
                fetchGenresList()
                }
                
            }  catch  {
                print("TAG : \(error.localizedDescription)")
            }
      
    }
    
    private func fetchGenresList(){
        if NetworkUtils.checkReachable() == false {
            Dialog.showAlert(viewController: self, title: "Error", message: "No internet connection")
            return
        }
        MovieModel.shared.fetchMovieGenres{
            genreInfoResponse in
            MovieGenreVO.saveMovieGenereVO(data: genreInfoResponse, context: CoreDataStack.shared.viewContext)
        }
    }
    fileprivate func initMovieListFetchRequest() {
        //FetchRequest
        let fetchRequest : NSFetchRequest<MovieVO> = MovieVO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "popularity", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.viewContext, sectionNameKeyPath: nil
            , cacheName: nil)
        
        // to know controlller
        fetchRequestController.delegate = self
        
        
        do {
            try fetchRequestController.performFetch()
//            if let movie = fetchRequestController.fetchedObjects, movies.isEmpty{
//                self.fetchTopRatedMovies()
//            }
        } catch  {
            print("TAG : \(error.localizedDescription)")
        }
        
        
        //TODO : Fetch & Display Movie Info
        if let result = try? CoreDataStack.shared.viewContext.fetch(fetchRequest){
            if result.isEmpty{
                fetchTopRatedMovies()
            }else {
                bindData(movies: result)
            }
        }
    
        
        
    }
    
    fileprivate func bindData(movies: [MovieVO]){
        //self.movieVO = movies
        self.collectionViewMovieList.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Movie List"
    }

   
    
    
    fileprivate func fetchTopRatedMovies() {
        if NetworkUtils.checkReachable() == false {
            Dialog.showAlert(viewController: self, title: "Error", message: "No Internet Connection!")
            return
        }
        MovieModel.shared.fetchTopRatedMovies(pageId: 1) { [weak self] data in
            
            data.forEach({ (movieInfo) in
                MovieInfoResponse.saveMovieEntity(data: movieInfo, context: CoreDataStack.shared.viewContext)
            })
            
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
            
        }
    }
    
    
   
}

extension MovieListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return 1
        return fetchRequestController.sections?.count ?? 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // return movieVO.count
        return fetchRequestController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       // let movie = movieVO[indexPath.row]
       let movie = fetchRequestController.object(at: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.identifier, for: indexPath) as? MovieListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
//        print("Genre Count : \(movie.genres?.count ?? 0)")
        
        cell.data = movie
        return cell
    }
}

extension MovieListViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let movieDetailsViewController = segue.destination as? MovieDetailsViewController {
            
            if let indexPaths = collectionViewMovieList.indexPathsForSelectedItems, indexPaths.count > 0 {
                let selectedIndexPath = indexPaths[0]
               // let movie = movieVO[selectedIndexPath.row]
                let movie = fetchRequestController.object(at:selectedIndexPath)
                movieDetailsViewController.movieId = Int(movie.id)
                
                self.navigationItem.title = movie.original_title
            }
            
        }
    }
}


extension MovieListViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 3) - 10;
        return CGSize(width: width, height: width * 1.45)
    }
}


extension MovieListViewController : NSFetchedResultsControllerDelegate{
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionViewMovieList.reloadData()
    }
}

