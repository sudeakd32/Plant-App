
import UIKit
import Firebase
import Lottie
import Photos

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    private var animationView: LottieAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        setupLottieAnimation()
    }
    
    private func setupLottieAnimation() {
        animationView = .init(name: "Animation")
        guard let animationView = animationView else { return }
        
        animationView.frame = CGRect(
            x: 20,
            y: imageView.frame.maxY + 200,
            width: view.frame.width - 40,
            height: 120
        )
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        
        view.addSubview(animationView)
        animationView.play()
    }
    
    
    @objc private func imageTapped() {
        let alertController = UIAlertController(title: "Select Photo", message: "Choose from your saved plants", preferredStyle: .actionSheet)
        
        // Only saved plants option
        alertController.addAction(UIAlertAction(title: "My Saved Plants", style: .default) { _ in
            self.showSavedPlants()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alertController, animated: true)
    }
    
    
    @IBAction func uploadButtonTouched(_ sender: Any) {
        guard let image = imageView.image,
              let comment = commentTextField.text, !comment.isEmpty else {
            showAlert(title: "Error", message: "Please select a photo and write a comment.")
            return
        }
        
        uploadImageToFirestore(image: image, comment: comment)
    }
    
    private func uploadImageToFirestore(image: UIImage, comment: String) {
        guard let base64String = convertImageToBase64(image: image) else {
            showAlert(title: "Error", message: "An error occurred while processing the photo.")
            return
        }
        
        let firestoreDatabase = Firestore.firestore()
        
        let firestorePost = [
            "comment": comment,
            "email": Auth.auth().currentUser?.email ?? "unknown",
            "date": FieldValue.serverTimestamp(),
            "imageBase64": base64String
        ] as [String: Any]
        
        firestoreDatabase.collection("Post").addDocument(data: firestorePost) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "An error occurred while sharing the post: \(error.localizedDescription)")
                } else {
                    print("Post successfully uploaded.")
                    self?.resetUploadForm()
                    self?.showAlert(title: "Success", message: "Your post has been shared successfully!")
                }
            }
        }
    }
    
    private func resetUploadForm() {
        commentTextField.text = ""
        imageView.image = UIImage(named: "plantPictureUpload")
        tabBarController?.selectedIndex = 0
    }

    
    @IBAction func saveMyPlant(_ sender: Any) {
        guard let image = imageView.image else {
            showAlert(title: "Error", message: "Please select a photo to save.")
            return
        }
        
        requestPhotoLibraryPermission { [weak self] granted in
            if granted {
                self?.saveImageToPhotosAlbum(image: image)
            } else {
                self?.showAlert(title: "Permission Required", message: "Please grant photo access permission from Settings to save the photo.")
            }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    completion(true)
                case .denied, .restricted, .notDetermined:
                    completion(false)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
    private func saveImageToPhotosAlbum(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.createOrUpdateAlbum(with: image)
                } else {
                    print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                    self?.showAlert(title: "Error", message: "An error occurred while saving the photo.")
                }
            }
        }
    }
    
    private func createOrUpdateAlbum(with image: UIImage) {
        let albumName = "MyPlantApp"
        
        // Check album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = albums.firstObject {
            addImageToExistingAlbum(image: image, album: album)
        } else {
            createNewAlbumWithImage(image: image, albumName: albumName)
        }
    }
    
    private func addImageToExistingAlbum(image: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            if let placeholder = assetRequest.placeholderForCreatedAsset {
                albumChangeRequest?.addAssets([placeholder] as NSArray)
            }
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Success", message: "Plant photo saved to MyPlantApp album! 🌸")
                } else {
                    self?.showAlert(title: "Success", message: "Photo saved!")
                }
            }
        }
    }
    
    private func createNewAlbumWithImage(image: UIImage, albumName: String) {
        PHPhotoLibrary.shared().performChanges({
            let albumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let placeholder = assetRequest.placeholderForCreatedAsset {
                albumRequest.addAssets([placeholder] as NSArray)
            }
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.showAlert(title: "Success", message: "Plant photo saved to MyPlantApp album! 🌸")
                } else {
                    self?.showAlert(title: "Success", message: "Photo saved!")
                }
            }
        }
    }
 
    private func showSavedPlants() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.fetchAndShowSavedPlants()
                case .denied, .restricted, .notDetermined:
                    self?.showAlert(title: "Permission Required", message: "Please grant photo access permission from Settings to view saved plants.")
                @unknown default:
                    self?.showAlert(title: "Permission Required", message: "Photo access permission required.")
                }
            }
        }
    }
    
    private func fetchAndShowSavedPlants() {
        let albumName = "MyPlantApp"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        guard let album = albums.firstObject else {
            showAlert(title: "Info", message: "You don't have any saved plant photos yet.")
            return
        }
        
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let assets = PHAsset.fetchAssets(in: album, options: assetFetchOptions)
        
        if assets.count == 0 {
            showAlert(title: "Info", message: "You don't have any saved plant photos yet.")
            return
        }
        
        showPhotoPickerFromAlbum(assets: assets)
    }
    
    private func showPhotoPickerFromAlbum(assets: PHFetchResult<PHAsset>) {
        let alertController = UIAlertController(title: "My Saved Plants", message: "Select the photo you want to share", preferredStyle: .actionSheet)
        
        let count = min(assets.count, 8)
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        for i in 0..<count {
            let asset = assets.object(at: i)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            let dateString = dateFormatter.string(from: asset.creationDate ?? Date())
            
            let action = UIAlertAction(title: "Plant \(i + 1) - \(dateString)", style: .default) { _ in
                self.loadImageFromAsset(asset: asset, imageManager: imageManager, options: requestOptions)
            }
            alertController.addAction(action)
        }
        
        if assets.count > 8 {
            alertController.addAction(UIAlertAction(title: "More available...", style: .default) { _ in
                self.showAlert(title: "Info", message: "For more photos, you can check the MyPlantApp album in Settings > Photos.")
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    private func loadImageFromAsset(asset: PHAsset, imageManager: PHImageManager, options: PHImageRequestOptions) {
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let image = image {
                    self?.imageView.image = image
                    self?.commentTextField.text = "My beautiful plant 🌸"
                }
            }
        }
    }
    
    // MARK: - Plant Creator Integration
    
    func setImageFromPlantCreator(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
            self.commentTextField.text = "My beautiful plant 🌸"
        }
    }
    
    private func convertImageToBase64(image: UIImage) -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return nil }
        return imageData.base64EncodedString()
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
    
    
    
    
    
    
    
    
    
    
    
    

