//
//  ViewController.swift
//  URLProtocols
//
//  Created by Ben Scheirman on 1/5/21.
//

import UIKit

class ViewController: UIViewController {
    
    let session = URLSession.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://test.host/api/account/165/projects")!
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let http = response as? HTTPURLResponse {
                print("HTTP \(http.statusCode)")
            }
            
            if let error = error {
                print("ERROR: \(error)")
            } else if let data = data {
                let body = String(data: data, encoding: .utf8) ?? "<?>"
                print("Response: \(body)")
            }
        }
        
        task.resume()
    }


}

