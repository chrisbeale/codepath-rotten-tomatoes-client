//
//  MoviesViewController.swift
//  RottenTomatos
//
//  Created by Chris Beale on 4/14/15.
//  Copyright (c) 2015 Chris Beale. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var moviesTableView: UITableView!
    
    @IBOutlet weak var errorDialog: UIView!
    
    private var movies = NSArray();
    private var refreshControl: UIRefreshControl!
    private var category: MovieCategory = .BoxOffice
    
    enum MovieCategory { case BoxOffice, DVD }
    
    func setCategory(category: MovieCategory) {
        self.category = category;
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        
        self.title = category == .BoxOffice ? "Box Office" : "DVD"
        
        SVProgressHUD.show()
        loadMovies({
            SVProgressHUD.dismiss()
        })
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        moviesTableView.insertSubview(refreshControl, atIndex: 0)
        
        errorDialog.hidden = true;
    }
    
    func loadMovies(callback: () -> Void) {
        
        let YourApiKey = "dagqdghwaq3e3mxyrp7kmmj5" // Fill with the key you registered at http://developer.rottentomatoes.com
        
        let movieCategory = self.category == .BoxOffice ? "movies/box_office" : "dvds/top_rentals"
        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/\(movieCategory).json?apikey=" + YourApiKey
    
        let url = NSURL(string: RottenTomatoesURLString)
        
        let request = NSMutableURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{ (response, data, error) in
            
            if error == nil {
                self.errorDialog.hidden = true;
                var errorValue: NSError? = nil
                let dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &errorValue) as! NSDictionary
                self.movies = dictionary["movies"] as! NSArray
                self.moviesTableView.reloadData()
            } else {
                println("Error raised: \(error)")
                 self.errorDialog.hidden = false
            }
            
            callback()
            
        })
    }
    
    func onRefresh() {
        loadMovies({
            self.refreshControl.endRefreshing()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movies.count > 0 {
            return movies.count
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies[indexPath.row] as! NSDictionary
        
        cell.titleLabel?.text = movie["title"] as? String
        cell.synopsisLabel?.text = movie["synopsis"] as? String
        
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
        var range = urlString.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlString = urlString.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        let url = NSURL(string: urlString)
        
        cell.movieImage.setImageWithURL(url);
        
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPathForCell(cell)!
        let movie = movies[indexPath.row] as! NSDictionary
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

}
