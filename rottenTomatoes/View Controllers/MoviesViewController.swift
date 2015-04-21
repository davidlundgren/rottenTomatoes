//
//  MoviesViewController.swift
//  rottenTomatoes
//
//  Created by David Lundgren on 4/18/15.
//  Copyright (c) 2015 David Lundgren. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    func loadData() {
        let YourApiKey = "dagqdghwaq3e3mxyrp7kmmj5"
        let RottenTomatoesURLString = "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=" + YourApiKey
        
        let url = NSURL(string: RottenTomatoesURLString)!
        let request = NSURLRequest(URL: url)
        let alert = UIAlertView(title: "Zomg Error", message: "Could not connect to the interwebs.", delegate: self, cancelButtonTitle: "Dismiss")
        
        SVProgressHUD.show()
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                alert.show()
            }
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            if let json = json {
                self.movies = json["movies"] as! [NSDictionary]
            } else {
                alert.show()
            }
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = movies![indexPath.row]
        var urlString = movie.valueForKeyPath("posters.thumbnail") as! String
        let url = NSURL(string: urlString)!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        cell.titleLabel.text = movie["title"] as! String
        cell.synopsisLabel.text = movie["synopsis"] as! String
        cell.posterView.setImageWithURL(url)
        cell.accessoryType = UITableViewCellAccessoryType.None

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }

    func onRefresh() {
        self.loadData()
        self.refreshControl.endRefreshing()
    }
    
}
