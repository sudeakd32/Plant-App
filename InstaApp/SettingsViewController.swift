

import UIKit
import Firebase
import Photos
import Lottie

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var savedPlants: [PHAsset] = []
    private let imageManager = PHImageManager.default()
    private var animationView: LottieAnimationView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadSavedPlants()
        setupLottieAnimation()
    }
    
    private func setupLottieAnimation() {
        animationView = .init(name: "Animation1")
        
        guard let animationView = animationView else { return }
        animationView.frame = CGRect(
            x: 15,
            y: tableView.frame.maxY + 30,
            width: view.frame.width - 30,
            height: 120
        )
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        
        view.addSubview(animationView)
        animationView.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSavedPlants()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SavedPlantTableViewCell.self, forCellReuseIdentifier: "SavedPlantCell")
        tableView.rowHeight = 100
    }
    
    private func loadSavedPlants() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.fetchSavedPlants()
                case .denied, .restricted, .notDetermined:
                    self?.showAlert(title: "Permission Required", message: "Please grant photo access permission from Settings to view saved plants.")
                @unknown default:
                    self?.showAlert(title: "Permission Required", message: "Photo access permission required.")
                }
            }
        }
    }
    
    private func fetchSavedPlants() {
        let albumName = "MyPlantApp"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        guard let album = albums.firstObject else {
            savedPlants = []
            tableView.reloadData()
            return
        }
        
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(in: album, options: assetFetchOptions)
        
        savedPlants = []
        for i in 0..<assets.count {
            savedPlants.append(assets.object(at: i))
        }
        
        tableView.reloadData()
    }
    
    private func deletePlant(at indexPath: IndexPath) {
        let asset = savedPlants[indexPath.row]
        
        let alertController = UIAlertController(title: "Delete Plant", message: "Are you sure you want to delete this plant photo?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.performDelete(asset: asset, at: indexPath)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    private func performDelete(asset: PHAsset, at indexPath: IndexPath) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.savedPlants.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                    self?.showAlert(title: "Success", message: "Plant photo deleted successfully.")
                } else {
                    print("Error deleting asset: \(error?.localizedDescription ?? "Unknown error")")
                    self?.showAlert(title: "Error", message: "Failed to delete the photo.")
                }
            }
        }
    }
    
    @IBAction func exitTouched(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
        } catch {
            print("Error signing out")
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPlants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedPlantCell", for: indexPath) as! SavedPlantTableViewCell
        let asset = savedPlants[indexPath.row]
        
        // Load image
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 80, height: 80), contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                cell.configure(with: image, date: asset.creationDate)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletePlant(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

class SavedPlantTableViewCell: UITableViewCell {
    
    private let plantImageView = UIImageView()
    private let dateLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(plantImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        plantImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        plantImageView.contentMode = .scaleAspectFill
        plantImageView.clipsToBounds = true
        plantImageView.layer.cornerRadius = 8
        plantImageView.backgroundColor = UIColor.systemGray5
        
        titleLabel.text = "My Plant 🌸"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor.systemGray
        
        NSLayoutConstraint.activate([
            plantImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            plantImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plantImageView.widthAnchor.constraint(equalToConstant: 80),
            plantImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            dateLabel.leadingAnchor.constraint(equalTo: plantImageView.trailingAnchor, constant: 16),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with image: UIImage?, date: Date?) {
        plantImageView.image = image ?? UIImage(systemName: "photo")
        
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = "Unknown date"
        }
    }
}
