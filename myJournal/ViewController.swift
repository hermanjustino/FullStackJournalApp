//
//  ViewController.swift
//  myJournal
//
//  Created by Herman Justino on 2021-05-06.
//

import UIKit

struct Post: Decodable {
    
    let id: Int
    let title, body: String
    
}

class ViewController: UITableViewController {
    
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        
        print("Perform loginand refetch posts")
        
        guard let url = URL(string: "http://localhost:1337/api/v1/entrance/login") else {return}
       
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "PUT"
        
        do {
            
            let params = ["emailAddress": "nemo@hotmail.com", "password": "marlin"]
            
            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.downloadTask(with: loginRequest) { (data, resp, err) in
                
                if let err = err {
                    print("failed to log in: ", err)
                    return
                }
                
                print("Probably logged in ")
                self.fetchPosts()
                
            }.resume()
            
        } catch {
            print("failed to serialize data", error)
        }
            
    }
    
    @IBAction func btnCreateClicked(_ sender: UIButton) {
        print("creating Post...")
        Service.shared.createPost(title: "IOS Title", body: "IOS Post Body") {
            (err) in
            if let err = err {
                print("Failed to create post body", err)
                return
            }
            print("Finished creating post")
            self.fetchPosts()
        }
        
    }
    var posts = [Post]()
    
    fileprivate func fetchPosts() {
        Service.shared.fetchPosts() { (res) in
            switch res {
            case .failure(let err):
                print("Failed to fetch posts: ", err)
            case .success(let posts) :
                print(posts)
            
                self.posts = posts
                
                self.tableView.reloadData()
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("delete post")
            
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id) { (err) in
                if err != nil {
                    print("Failed to delete")
                    return
                }
                
                print("Successfully deleted post from server")
                
                self.posts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        let post = posts[indexPath.row]
        
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        
        return cell
    }
    
    

    override func viewDidLoad() {
        
        fetchPosts()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

