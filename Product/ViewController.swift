//
//  ViewController.swift
//  Product
//
//  Created by bola fayez on 7/7/15.
//  Copyright (c) 2015 Bola Fayez. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var dateResponse:NSString!

    var data:NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Connection.isConnectedToNetwork() == true {
            // connection OK .
            
            self.getProducts(url: "http://grapesnberries.getsandbox.com/products?count=10&from=1") { (succeeded: Bool, msg: String) -> () in
                println("happen error")
            }

        } else {
            // connection FAILED
            
            let alert = UIAlertView()
                alert.title = "Connection"
                alert.message = "Connection Error"
                alert.addButtonWithTitle("Ok")
                alert.show()
        }
        
        
    }

    // delegate methods collectionView .
    
    //  number of items
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data.count
    }
    
    // cell of item
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
        let cell: cellCollectionView = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! cellCollectionView

        let obj: AnyObject      = self.data.objectAtIndex(indexPath.row)
        let image               = obj.valueForKey("image")              as? NSDictionary
        let desc                = obj.valueForKey("productDescription") as! String
        var price               = obj.valueForKey("price")              as! Int
        let imageURL: AnyObject = image!.valueForKey("url")!
        let highImage           = image!.valueForKey("height")!         as! Int
        let widthImage          = image!.valueForKey("width")!          as! Int
            

        var urls = NSURL(string: imageURL as! String)
        var data = NSData(contentsOfURL: urls!)
            
        cell.imageProduct.image           = UIImage(data: data!)
        cell.labelProductDescription.text = desc
        cell.labelPrice.text              = String(price)

        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, CGFloat(widthImage), CGFloat(highImage))

        return cell
    }
    
    // when select item
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Cell \(indexPath.row) selected")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // calling webservice
    func getProducts(#url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var err: NSError?
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            self.dateResponse = NSString(data: data, encoding: NSUTF8StringEncoding)

            var parseError: NSError?
            let parsedObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.AllowFragments,
                error:&parseError)
            let json = parsedObject as! NSArray
            
            for item in json {
                
                let itemDic  = item   as! NSDictionary
                self.data.addObject(itemDic)
                
              }
            
            self.collectionView.reloadData()
            
        })
        task.resume()
    }

}

