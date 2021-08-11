//
//  RequestsViewController.swift
//  App
//
//  Created by Rahul Guni on 8/7/21.
//

import UIKit

class RequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var requestsTable: UITableView!
    
    private var requests : [Request] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        requestsTable.delegate = self
        requestsTable.dataSource = self
    }
    
    func setRequests(requests currRequests: [Request]) {
        self.requests = currRequests
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableRequestsCell") as! RequestsTableViewCell
        cell.setParameters(request: requests[indexPath.row])
        return cell
    }

}
