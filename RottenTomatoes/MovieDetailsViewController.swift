//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by James Tang on 9/11/15.
//  Copyright © 2015 Codepath. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var synopsisTextView: UITextView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        synopsisTextView.text = movie["synopsis"] as? String
        synopsisTextView.textColor = UIColor.whiteColor()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        var url = movie.valueForKeyPath("posters.thumbnail") as! String
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        if let checkedUrl = NSURL(string: url) {
            //NSLog("\(checkedUrl)")
            downloadImage(checkedUrl, imageView: self.imageView)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
