//
//  ImageViewExtensions.swift
//  NetworkingDemo
//
//  Created by Ben Scheirman on 11/9/14.
//  Copyright (c) 2014 NSScreencast. All rights reserved.
//

import UIKit
import ObjectiveC

var sessionKey = "session"
var taskKey = "task"
var imageCacheKey = "cache"

extension UIImageView {
    var session: NSURLSession? {
        get {
            return objc_getAssociatedObject(UIImageView.self, &sessionKey) as NSURLSession?
        }
        set {
            objc_setAssociatedObject(UIImageView.self, &sessionKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    var imageTask: NSURLSessionTask? {
        get {
            return objc_getAssociatedObject(self, &taskKey) as NSURLSessionTask?
        }
        set {
            objc_setAssociatedObject(self, &taskKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    func loadImageFromURL(url: NSURL, placeholder: UIImage? = nil) {
        if session == nil {
            session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        }
        
        imageTask?.cancel()
        image = placeholder
        imageTask = session?.dataTaskWithURL(url) {
            (data, response, error) in
            if error == nil {
                let http = response as NSHTTPURLResponse
                if http.statusCode == 200 {
                    let image = UIImage(data: data)
                    if self.imageTask?.state == NSURLSessionTaskState.Canceling {
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        println("\(url) finished: \(image)")
                        self.image = image
                        self.setNeedsDisplay()
                    }
                } else {
                    println("\(url) -> HTTP \(http.statusCode)")
                }
            } else {
                println("error with \(url): \(error)")
            }
            self.imageTask = nil
        }
        imageTask?.resume()
    }
}
