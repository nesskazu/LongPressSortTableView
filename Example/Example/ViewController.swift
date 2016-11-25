//
//  ViewController.swift
//  Example
//
//  Created by Yoshitaka Kazue on 2016/11/25.
//  Copyright © 2016年 Yoshitaka Kazue. All rights reserved.
//

import UIKit
import LongPressSortTableView

class ViewController: UIViewController {
    
    @IBOutlet var tableView: LongPressSortTableView!
    
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10","11", "12", "13", "14", "15", "16", "17", "18", "19", "20","21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.moveDelegate = self
    }

}

extension ViewController: LongPressSortTableViewDelegate {
    
    func didMoveRow(at initialIndexPath: IndexPath, to indexPath: IndexPath) {
        swap(&items[initialIndexPath.row], &items[indexPath.row])
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String(items[indexPath.row])
        return cell
    }
    
}
