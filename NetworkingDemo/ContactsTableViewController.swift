//
//  ContactsTableViewController.swift
//  NetworkingDemo
//
//  Created by ben on 3/3/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController, NSURLSessionDataDelegate {
    
    var responseData: NSMutableData?
    var contacts: [[String: AnyObject]] = []
    
    lazy var config: NSURLSessionConfiguration = {
       return NSURLSessionConfiguration.defaultSessionConfiguration()
    }()
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.config, delegate: self, delegateQueue: nil)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string:
            "http://cache-tester.herokuapp.com/contacts.json?expires=1"
        )!
        let req = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        
        if let cachedResponse = config.URLCache?.cachedResponseForRequest(req) {
            parseContacts(cachedResponse.data)
        }
        
        let task = session.dataTaskWithRequest(req)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let t: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 2 * Int64(NSEC_PER_SEC))
        dispatch_after(t, dispatch_get_main_queue()) {
            task.resume()
        }
    }
    
    // MARK - NSURLSessionDataDelegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if responseData == nil {
            responseData = NSMutableData()
        }
        
        responseData?.appendData(data)
    }
    
    func URLSession(session: NSURLSession,
        dataTask: NSURLSessionDataTask,
        willCacheResponse proposedResponse: NSCachedURLResponse,
        completionHandler: NSCachedURLResponse! -> ()) {
        
            completionHandler(proposedResponse)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask,
        didReceiveResponse response: NSURLResponse,
        completionHandler: (NSURLSessionResponseDisposition) -> Void) {

            let http = response as NSHTTPURLResponse
            println("Received headers: ")
            for (k,v) in http.allHeaderFields {
                println("  \(k): \(v)")
            }
            completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if error == nil {
            let http = task.response as NSHTTPURLResponse
            if http.statusCode == 200 {
                if task.originalRequest.URL.lastPathComponent == "contacts.json" {
                    parseContacts(responseData!)
                } else {
                    println("Response:")
                    let body = NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                    println("\(body)")
                }
                responseData = nil
            } else {
                println("Got an HTTP \(http.statusCode)")
            }
        } else {
            println("Error: \(error)")
        }
    }
    
    func parseContacts(data: NSData) {
        let contacts = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as [ [String:AnyObject] ]
        self.contacts = contacts
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    // MARK - TableView

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let contact = contacts[indexPath.row] as NSDictionary
        cell.textLabel?.text = contact["name"] as? String

        return cell
    }
}
