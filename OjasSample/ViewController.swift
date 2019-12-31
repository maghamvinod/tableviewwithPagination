//
//  ViewController.swift
//  OjasSample
//
//  Created by KvanaNewMac on 30/12/19.
//  Copyright © 2019 kvana. All rights reserved.
//

import UIKit
import Alamofire
class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var sampleArray:[Sample] = []
    var currentPage = 1
    var totoalCount  = 1
    var totalPages:Int?
    let perpage = 11
    var activityScrollView: UIActivityIndicatorView?
    var isLoading : Bool = false
    @IBOutlet var sampleTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getData()
    }
    
    //Pagination
    func incrementPage(){
        currentPage = currentPage + 1
    }
    //to reset the pages
    func resetCounter() {
        currentPage = 0
    }
    //Scroll view in view controller
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if(currentPage < totalPages ?? 0){
            if(sampleArray.count >= 11){
                let offset = scrollView.contentOffset.y
                let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
                if (maxOffset - offset) <= 40 {
                    self.loadtableView()
                }
            }
        }
    }
    
    //to loadtableView
    func loadtableView(){
        self.isLoading = true
        activityScrollView?.startAnimating()
        self.incrementPage()
        self.getData()
    }
    
    func getData(){
        Alamofire.request("https://hn.algolia.com/api/v1/search_by_date?tags=story&page=" + String(currentPage), method: .get, parameters: nil, encoding: JSONEncoding.default,headers: nil)
            .responseJSON { response in
                if let responseData = response.result.value as? [String: Any]{
                    if let somthing = responseData["hits"] as? [[String:Any]]{
                        self.totalPages = responseData["nbPages"] as? Int
                        for(i,object) in somthing.enumerated(){
                            let sample = Sample()
                            
                            sample.title = (object as AnyObject)["title"] as? String
                            sample.createdAt = (object as AnyObject)["created_at"] as? String
                            self.sampleArray.append(sample)
                        }
                        DispatchQueue.main.async {
                            self.sampleTableView.reloadData()
                        }
                    }
                }
                
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            // print("this is the last cell")
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.sampleTableView.tableFooterView = spinner
            self.sampleTableView.tableFooterView?.isHidden = false
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  sampleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var latestCell = tableView.dequeueReusableCell(withIdentifier: "sample")
        
        if latestCell == nil {
            latestCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "sample")
        }
        latestCell?.textLabel?.text = sampleArray[indexPath.row].title
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy h:mm a"
        let date: Date? = dateFormatterGet.date(from:String(sampleArray[indexPath.row].createdAt ?? ""))
        latestCell?.detailTextLabel?.text = dateFormatter.string(from: date!)
        return latestCell!
        
    }
    
    
}

