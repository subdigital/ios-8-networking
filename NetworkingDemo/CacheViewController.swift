//
//  CacheViewController.swift
//  NetworkingDemo
//
//  Created by ben on 3/3/15.
//  Copyright (c) 2015 NSScreencast. All rights reserved.
//

import UIKit

class CacheViewController: UIViewController {

    @IBOutlet weak var cacheStatusLabel: UILabel!
    
    var cachesDir: NSString {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, .UserDomainMask, true)
        return paths.first! as String
    }
    
    var bundleIdentifier: NSString {
        return NSBundle.mainBundle().bundleIdentifier!
    }
    
    var cachesPath: NSString {
        return cachesDir.stringByAppendingPathComponent("\(bundleIdentifier)/Cache.db")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        println("Cache database: \(cachesPath)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCacheStatus()
    }
    
    func updateCacheStatus() {
        let fileMgr = NSFileManager.defaultManager()
        
        if fileMgr.fileExistsAtPath(cachesPath) {
            let attribs = fileMgr.attributesOfItemAtPath(cachesPath, error: nil)!
            let fileSizeInBytes = attribs[NSFileSize] as Int
            let fileSizeInKb = Float(fileSizeInBytes) / 1024.0
            
            let cache = NSURLCache.sharedURLCache()
            let curMem = Float(cache.currentMemoryUsage) / 1024.0 / 1024.0
            let memCap = Float(cache.memoryCapacity) / 1024.0 / 1024.0
            let curDisk = Float(cache.currentDiskUsage) / 1024.0 / 1024.0
            let diskCap = Float(cache.diskCapacity) / 1024.0 / 1024.0
            cacheStatusLabel.text = "Cache database: \(fileSizeInKb) KB\n Mem: \(curMem) MB / \(memCap) MB\n Disk: \(curDisk) MB / \(diskCap) MB"
        } else {
            cacheStatusLabel.text = "Cache database not present"
        }
    }

    @IBAction func clearCacheTapped(sender: AnyObject) {
        NSFileManager.defaultManager().removeItemAtPath(cachesPath, error: nil)
        updateCacheStatus()
    }
    
}
