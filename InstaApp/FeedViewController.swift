
import UIKit
import Firebase
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    
    var emails : [String] = []
    var comments : [String] = []
    var images : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        getFirebaseData()
    }
    
    
    func getFirebaseData(){
        
        let fireStoreDatabase = Firestore.firestore()
        fireStoreDatabase.collection("Post").order(by:"date", descending: true).addSnapshotListener { (snapshot, error) in
            if error != nil{
                print("Error fetching data")
            }else{
                
                self.comments.removeAll()
                self.emails.removeAll()
                self.images.removeAll()
                
                if snapshot?.isEmpty != true && snapshot != nil{
                    for document in snapshot!.documents{
        
                        if let comment = document.get("comment") as? String{
                            self.comments.append(comment)
                        }
                        if let email = document.get("email") as? String{
                            self.emails.append(email)
                        }
                        if let base64 = document.get("imageBase64") as? String,
                              let imageData = Data(base64Encoded: base64),
                                    let image = UIImage(data: imageData) {
                                                        self.images.append(image)
                                                } else {
                                                    self.images.append(UIImage(named: "plantPictureUpload")!)
                                                }
                       
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
        cell.emailTextField.text = emails[indexPath.row]
        cell.commentTextField.text = comments[indexPath.row]
        cell.postImageView.image = images[indexPath.row]
        
        return cell
    }
    
    


}
