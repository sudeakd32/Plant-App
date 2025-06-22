//
//  yourPlantViewController.swift
//  InstaApp
//
//  Created by Sude on 15.06.2025.
//

import UIKit
import Photos
class yourPlantViewController: UIViewController {
    
    @IBOutlet weak var flower8Image: UIImageView!
    @IBOutlet weak var flower7Image: UIImageView!
    @IBOutlet weak var flower6Image: UIImageView!
    @IBOutlet weak var flower5Image: UIImageView!
    @IBOutlet weak var flower4Image: UIImageView!
    @IBOutlet weak var flower3Image: UIImageView!
    @IBOutlet weak var flower2Image: UIImageView!
    @IBOutlet weak var flower1Image: UIImageView!
    @IBOutlet weak var vaseImage: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    var flowersInVase: [UIImageView] = []
    var originalPositions: [UIImageView: CGPoint] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFlowerImages()
        setupVaseDropZone()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Vazo frame at viewDidLoad: \(self.vaseImage.frame)")
        }
    }
    
    func setupFlowerImages() {
        let flowerImages = [flower1Image, flower2Image, flower3Image, flower4Image,
                            flower5Image, flower6Image, flower7Image, flower8Image]
        
        for flowerImage in flowerImages {
            guard let flowerImage = flowerImage else { continue }
            
            originalPositions[flowerImage] = flowerImage.center
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            flowerImage.addGestureRecognizer(panGesture)
            flowerImage.isUserInteractionEnabled = true
        }
    }
    
    func setupVaseDropZone() {
        vaseImage.isUserInteractionEnabled = true
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view as? UIImageView else { return }
        
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .began:
            view.bringSubviewToFront(draggedView)
            
        case .changed:
            draggedView.center = CGPoint(x: draggedView.center.x + translation.x,
                                         y: draggedView.center.y + translation.y)
            gesture.setTranslation(.zero, in: view)
            
        case .ended:
            handleDropGesture(draggedView)
            
        default:
            break
        }
    }
    
    func handleDropGesture(_ draggedView: UIImageView) {
        
        if draggedView.frame.intersects(vaseImage.frame) {
            createFlowerCopyInVase(from: draggedView)
            returnToOriginalPosition(draggedView)
        } else {
            returnToOriginalPosition(draggedView)
        }
    }
    
    func createFlowerCopyInVase(from originalFlower: UIImageView) {
        let flowerCopy = UIImageView(image: originalFlower.image)
        flowerCopy.contentMode = originalFlower.contentMode
        flowerCopy.frame = originalFlower.frame
        
        view.addSubview(flowerCopy)
        
        flowersInVase.append(flowerCopy)
        
        let dropPosition = originalFlower.center
        
        UIView.animate(withDuration: 0.2) {
            flowerCopy.center = dropPosition
        }
    }
    
    func returnToOriginalPosition(_ flowerView: UIImageView) {
        guard let originalPosition = originalPositions[flowerView] else { return }
        
        UIView.animate(withDuration: 0.3) {
            flowerView.center = originalPosition
            flowerView.transform = .identity
        }
    }
    
    @IBAction func undoButton(_ sender: Any) {
        undoLastFlower()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        resetVase()
    }
    
    func undoLastFlower() {
        guard let lastFlowerCopy = flowersInVase.last else {
            print("There is no flower in your vase!")
            return
        }
        
        flowersInVase.removeLast()
        
        UIView.animate(withDuration: 0.3, animations: {
            lastFlowerCopy.alpha = 0
        }) { _ in
            lastFlowerCopy.removeFromSuperview()
        }
    }
    
    func resetVase() {
        for flowerCopy in flowersInVase {
            UIView.animate(withDuration: 0.3, animations: {
                flowerCopy.alpha = 0
            }) { _ in
                flowerCopy.removeFromSuperview()
            }
        }
        flowersInVase.removeAll()
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        
          guard !flowersInVase.isEmpty else {
              showAlert(title: "Alert!", message: "Add a flower to your vase first!")
              return
          }

          let alertController = UIAlertController(title: "Save My Plant", message: "How do you want to save your plant?", preferredStyle: .actionSheet)
          
          alertController.addAction(UIAlertAction(title: "Save to your photos", style: .default) { _ in
              self.undoButton.isHidden = true
              self.resetButton.isHidden = true
              self.takeScreenshotAndSave()
              self.undoButton.isHidden = false
              self.resetButton.isHidden = false
          })
         
          alertController.addAction(UIAlertAction(title: "Prepare for upload", style: .default) { _ in
              self.undoButton.isHidden = true
              self.resetButton.isHidden = true
              self.prepareForSharing()
              self.undoButton.isHidden = false
              self.resetButton.isHidden = false
          })
          
          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
          
          present(alertController, animated: true)
        
     
      }

      private func takeScreenshotAndSave() {
          
          guard let screenshot = captureVaseAreaScreenshot() else {
              showAlert(title: "Error", message: "Screen capture failed!")
              return
          }

          checkPhotoLibraryPermissionAndSave(image: screenshot)
      }

      private func checkPhotoLibraryPermissionAndSave(image: UIImage) {
          let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
          
          switch status {
          case .authorized, .limited:
              saveImageToPhotosAlbum(image: image)
          case .notDetermined:
              PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                  DispatchQueue.main.async {
                      if newStatus == .authorized || newStatus == .limited {
                          self?.saveImageToPhotosAlbum(image: image)
                      } else {
                          self?.showAlert(title: "Permission Required", message: "Please grant photo access permission from Settings to save the photo.")
                      }
                  }
              }
          case .denied, .restricted:
              showAlert(title: "Permission Required", message: "Please grant photo access permission from Settings to save the photo.")
          @unknown default:
              showAlert(title: "Permission Required", message: "Photo access permission required.")
          }
      }

      private func prepareForSharing() {
          guard let screenshot = captureVaseAreaScreenshot() else {
              showAlert(title: "Error", message: "Screenshot could not be taken.")
              return
          }
          
          // Navigate to upload screen
          if let tabBarController = self.tabBarController {
              tabBarController.selectedIndex = 1 // Check upload tab index
              
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                  if let navController = tabBarController.selectedViewController as? UINavigationController,
                     let uploadVC = navController.viewControllers.first as? UploadViewController {
                      uploadVC.setImageFromPlantCreator(image: screenshot)
                  } else if let uploadVC = tabBarController.selectedViewController as? UploadViewController {
                      uploadVC.setImageFromPlantCreator(image: screenshot)
                  }
              }
          }
      }


      private func captureVaseAreaScreenshot() -> UIImage? {
          guard !flowersInVase.isEmpty else { return nil }
          
          guard Thread.isMainThread else {
              var result: UIImage?
              DispatchQueue.main.sync {
                  result = self.captureVaseAreaScreenshot()
              }
              return result
          }
          
          // Calculate bounds of vase and flowers
          var minX: CGFloat = vaseImage.frame.minX
          var minY: CGFloat = vaseImage.frame.minY
          var maxX: CGFloat = vaseImage.frame.maxX
          var maxY: CGFloat = vaseImage.frame.maxY
          
          for flower in flowersInVase {
              if flower.frame.minX < minX { minX = flower.frame.minX }
              if flower.frame.minY < minY { minY = flower.frame.minY }
              if flower.frame.maxX > maxX { maxX = flower.frame.maxX }
              if flower.frame.maxY > maxY { maxY = flower.frame.maxY }
          }
          
          let padding: CGFloat = 5
          let captureRect = CGRect(
              x: max(0, minX - padding),
              y: max(0, minY - padding),
              width: min(view.bounds.width, (maxX - minX) + (2 * padding)),
              height: min(view.bounds.height, (maxY - minY) + (2 * padding))
          )
          
          let finalRect = captureRect.intersection(view.bounds)
          
          guard finalRect.width > 0 && finalRect.height > 0 else {
              print("Invalid capture rect: \(finalRect)")
              return nil
          }

          UIGraphicsBeginImageContextWithOptions(finalRect.size, false, UIScreen.main.scale)
          defer { UIGraphicsEndImageContext() }
          
          guard let context = UIGraphicsGetCurrentContext() else { return nil }
          
          context.setFillColor(UIColor.white.cgColor)
          context.fill(CGRect(origin: .zero, size: finalRect.size))
          
          context.saveGState()
          
          context.translateBy(x: -finalRect.origin.x, y: -finalRect.origin.y)
          
          view.layer.render(in: context)
          
          context.restoreGState()
          
          let screenshot = UIGraphicsGetImageFromCurrentImageContext()
          return screenshot
      }

      private func captureVaseAreaScreenshotAlternative() -> UIImage? {
          guard !flowersInVase.isEmpty else { return nil }
          
          var minX: CGFloat = vaseImage.frame.minX
          var minY: CGFloat = vaseImage.frame.minY
          var maxX: CGFloat = vaseImage.frame.maxX
          var maxY: CGFloat = vaseImage.frame.maxY
          
          for flower in flowersInVase {
              if flower.frame.minX < minX { minX = flower.frame.minX }
              if flower.frame.minY < minY { minY = flower.frame.minY }
              if flower.frame.maxX > maxX { maxX = flower.frame.maxX }
              if flower.frame.maxY > maxY { maxY = flower.frame.maxY }
          }
          
          let padding: CGFloat = 40
          let captureRect = CGRect(
              x: max(0, minX - padding),
              y: max(0, minY - padding),
              width: min(view.bounds.width, (maxX - minX) + (2 * padding)),
              height: min(view.bounds.height, (maxY - minY) + (2 * padding))
          )
          
          let renderer = UIGraphicsImageRenderer(bounds: captureRect)
          let image = renderer.image { context in
              UIColor.white.setFill()
              context.fill(captureRect)
        
              view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
          }
          
          return image
      }


      private func saveImageToPhotosAlbum(image: UIImage) {
          var localIdentifier: String?
          
          // First save the photo
          PHPhotoLibrary.shared().performChanges({
              let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
              localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
          }) { [weak self] success, error in
              DispatchQueue.main.async {
                  if success, let identifier = localIdentifier {
                      self?.addToCustomAlbum(assetIdentifier: identifier)
                  } else {
                      print("Error saving image: \(error?.localizedDescription ?? "Unknown error")")
                      self?.showAlert(title: "Success", message: "Photo saved to gallery!")
                  }
              }
          }
      }

      private func addToCustomAlbum(assetIdentifier: String) {
          let albumName = "MyPlantApp"
          
          // Check album
          let fetchOptions = PHFetchOptions()
          fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
          let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
          
          if let album = albums.firstObject {
              // Album exists, add asset
              addAssetToExistingAlbum(assetIdentifier: assetIdentifier, album: album)
          } else {
              // Album doesn't exist, create it
              createAlbumAndAddAsset(assetIdentifier: assetIdentifier, albumName: albumName)
          }
      }

      private func addAssetToExistingAlbum(assetIdentifier: String, album: PHAssetCollection) {
          let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
          guard let asset = assets.firstObject else {
              showAlert(title: "Success", message: "Photo saved to gallery!")
              return
          }
          
          PHPhotoLibrary.shared().performChanges({
              let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
              albumChangeRequest?.addAssets([asset] as NSArray)
          }) { [weak self] success, error in
              DispatchQueue.main.async {
                  if success {
                      self?.showAlert(title: "Success", message: "Plant photo saved to MyPlantApp album! 🌸")
                  } else {
                      print("Album add error: \(error?.localizedDescription ?? "Unknown")")
                      self?.showAlert(title: "Success", message: "Photo saved to gallery!")
                  }
              }
          }
      }

      private func createAlbumAndAddAsset(assetIdentifier: String, albumName: String) {
          let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
          guard let asset = assets.firstObject else {
              showAlert(title: "Success", message: "Photo saved to gallery!")
              return
          }
          
          PHPhotoLibrary.shared().performChanges({
              let albumCreationRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
              albumCreationRequest.addAssets([asset] as NSArray)
          }) { [weak self] success, error in
              DispatchQueue.main.async {
                  if success {
                      self?.showAlert(title: "Success", message: "Plant photo saved to MyPlantApp album! 🌸")
                  } else {
                      print("Album creation error: \(error?.localizedDescription ?? "Unknown error")")
                      self?.showAlert(title: "Success", message: "Photo saved to gallery!")
                  }
              }
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
