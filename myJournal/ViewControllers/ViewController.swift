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
    
    var email: UITextField!
        var password: UITextField!
    var confirm: UITextField!
    var fullName: UITextField!
    
    var postTitle: UITextField!
    var postBody: UITextField!
    

    
    var refresher: UIRefreshControl!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var btnNewNote: UIButton!
    
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBAction func btnSignClicked(_ sender: UIButton) {
        
        createForm(message: "Create an account for your very own notes!")
        
        
    }
    
    @objc func refresh(){
        self.tableView.reloadData()
        
        self.fetchPosts()
                self.refresher.endRefreshing()
            print("refreshed")
        }
    
    
    
    @IBAction func btnNewClicked(_ sender: UIButton) {
        createPost(message: "Create your newest Note!")
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        
        displayForm(message: "Please enter login information")
        
        print("Perform login and refetch posts")
        
       
    }
    
    func createPost(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
                
                //create cancel button
                let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel)
                
                //create save button
                let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
                   //validation logic goes here
                    if((self.postTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
                        || (self.postBody.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! ){
                        //if this code is run, that mean at least of the fields doesn't have value
                        self.postBody.text = ""
                        self.postTitle.text = ""
                        
                        self.displayForm(message: "One of the values entered was invalid. Please enter guest information")
                    }
                    
                    Service.shared.createPost(title: "\(String(describing: self.postTitle.text!))", body: "\(String(describing: self.postBody.text!))") {
                        (err) in
                        if let err = err {
                            print("Failed to create post body", err)
                            return
                        }
                        print("Finished creating post")
                        self.fetchPosts()
                    }
                }
                
                //add button to alert
                alert.addAction(cancelAction)
                alert.addAction(saveAction)
                
                //create first name textfield
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = "Enter title here..."
                    self.postTitle = textField
                })
                
                //create last name textfield
                alert.addTextField(configurationHandler: {(textField: UITextField!) in
                    textField.placeholder = "Note..."
                    self.postBody = textField
                })
                
               
                
                self.present(alert, animated: true, completion: nil)
            }
    
    func displayForm(message:String){
            //create alert
        
        
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            
            //create cancel button
            let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel)
            
            //create save button
            let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
               //validation logic goes here
                if((self.email.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
                    || (self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!){
                    //if this code is run, that mean at least of the fields doesn't have value
                    
                    self.email.text = ""
                    self.password.text = ""
                    
                    self.displayForm(message: "One of the values entered was invalid. Please enter guest information")
                }
                
                guard let url = URL(string: "http://localhost:1337/api/v1/entrance/login") else {return}
               
                var loginRequest = URLRequest(url: url)
                loginRequest.httpMethod = "PUT"
                
                do {
                    
                    let params = ["emailAddress": "\(self.email.text ?? "nil")", "password": "\(self.password.text ?? "nil")"]
                    
                    loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
                    
                    URLSession.shared.downloadTask(with: loginRequest) { (data, resp, err) in
                        
                        if let err = err {
                            print("failed to log in: ", err)
                            return
                        }
                        
                        print("Probably logged in ")
                        
                        self.fetchPosts()
                        
                        
                        DispatchQueue.main.async {
                            
                            self.navigationController?.navigationBar.barTintColor = .blue
                            self.btnSignUp.alpha = 0
                            self.btnLogin.alpha = 0
                            self.btnNewNote.alpha = 1
                        }
                        
                    }.resume()
                    
                } catch {
                    print("failed to serialize data", error)
                }
            }
            
            //add button to alert
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Type email here..."
                self.email = textField
            })
            
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Type password here..."
                self.password = textField
                self.password.isSecureTextEntry = true
            })
            
            
            self.present(alert, animated: true, completion: nil)
        }
    
    func createForm(message: String) {
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        //create cancel button
        let cancelAction = UIAlertAction(title: "Cancel" , style: .cancel)
        
        //create save button
        let saveAction = UIAlertAction(title: "Submit", style: .default) { (action) -> Void in
           //validation logic goes here
            if((self.email.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
                || (self.password.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
                || (self.confirm.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!){
                //if this code is run, that mean at least of the fields doesn't have value
                
                self.email.text = ""
                self.password.text = ""
                self.fullName.text = ""
                
                self.displayForm(message: "One of the values entered was invalid. Please enter guest information")
            }
            
            guard let url = URL(string: "http://localhost:1337/api/v1/entrance/signup") else {return}
           
            var signUpRequest = URLRequest(url: url)
            signUpRequest.httpMethod = "POST"
            
            do {
                
                let params = ["emailAddress": "\(self.email.text ?? "nil")", "password": "\(self.password.text ?? "nil")", "fullName": "\(self.fullName.text ?? "nil")"]
                
                signUpRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
                
                URLSession.shared.downloadTask(with: signUpRequest) { (data, resp, err) in
                    
                    if let err = err {
                        print("failed to create User: ", err)
                        return
                    }
                    
                    print("Probably created User ")
                    self.fetchPosts()
                    
                }.resume()
                
            } catch {
                print("failed to serialize data", error)
            }
        }
        
        //add button to alert
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter full name..."
            self.fullName = textField
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Type email here..."
            self.email = textField
        })
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Type password here..."
            self.password = textField
            self.password.isSecureTextEntry = true
        })
        
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Confirm Password..."
            self.confirm = textField
            self.confirm.isSecureTextEntry = true
        })
        
        self.present(alert, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = posts[indexPath.row]
        let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let viewController = storyboard?.instantiateViewController(identifier: "NoteVC") as? NoteVC {
            
            viewController.head = selectedCell.title
            viewController.head = selectedCell.body
            
            navigationController?.pushViewController(viewController, animated: true)
            
            
            viewController.title = posts[indexPath.row].title
            
        }
   
        print("you tapped me")
        
    }
    
    

    override func viewDidLoad() {
        
        refresher = UIRefreshControl()
               refresher.attributedTitle = NSAttributedString(string: "pull to refresh")

        refresher.addTarget(self, action: #selector(ViewController.refresh), for: UIControl.Event.valueChanged)
               self.tableView.addSubview(refresher)
               refresh()
        
        fetchPosts()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

