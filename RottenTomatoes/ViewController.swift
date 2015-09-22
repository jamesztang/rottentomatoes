//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by James Tang on 9/9/15.
//  Copyright © 2015 Codepath. All rights reserved.
//

import UIKit

private let CELL_NAME = "com.codepath.rottentomatoes.moviecell"

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var movieTableView: UITableView!
    var movies: NSArray?
    var refreshControl: UIRefreshControl!
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movieDictionary = movies![indexPath.row] as! NSDictionary
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_NAME) as! MovieCell
        cell.movieTitleLabel.text = movieDictionary["title"] as? String
        cell.movieDescriptionLabel.text = movieDictionary["synopsis"] as? String
        let releaseDate = movieDictionary["release_dates"] as! NSDictionary
        cell.movieYearLabel.text = releaseDate["theater"] as? String
        cell.movieRatingLabel.text = movieDictionary["mpaa_rating"] as? String
        cell.movieLengthLabel.text = movieDictionary["runtime"]?.description
        
        cell.movieImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        let url = movieDictionary.valueForKeyPath("posters.thumbnail") as! String
//        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
//        if let range = range {
//            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
//        }
        if let checkedUrl = NSURL(string: url) {
            //NSLog("\(checkedUrl)")
            downloadImage(checkedUrl, imageView: cell.movieImageView)
        }
        

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.movieTableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=f2fk8pundhpxf77fscxvkupy"
        let request = NSMutableURLRequest(URL: NSURL(string: RottenTomatoesURLString)!)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            if let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                dispatch_async(dispatch_get_main_queue()) {
                    self.movies = dictionary["movies"] as? NSArray
                    self.movieTableView.reloadData()                }
//                NSLog("Dictionary: \(dictionary)")
            }
            else {
                
            }
        }
        task.resume()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie as! NSDictionary
    }

    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            closure
        )
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }

    func downloadImage(url:NSURL, imageView: UIImageView) {
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                imageView.image = UIImage(data: data!)
            }
        }
    }
    
    func getDataFromUrl(urL: NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
        }.resume()
    }
}

class MovieCell: UITableViewCell {
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieLengthLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
}