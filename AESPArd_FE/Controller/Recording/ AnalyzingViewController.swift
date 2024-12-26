//
//  AnalysisVie.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/26/24.
//

import UIKit
import Photos
import AVKit

class AnalyzingViewController: UIViewController {
    var assetIdentifier: String?
    var videoAsset: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        assert(Thread.isMainThread, "viewDidLoad should be called on main thread")
        setupUI()
        fetchVideoAsset()
    }
    
    private func setupUI() {
        // Setup your UI elements here
        // For example, add a label to display the asset ID or a video player to play the video
    }
    
    private func fetchVideoAsset() {
        guard let identifier = assetIdentifier else {
            showAlert(title: "Error", message: "No video identifier provided.")
            return
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        if let asset = assets.firstObject {
            self.videoAsset = asset
            // Now you can use 'videoAsset' to perform further actions, like displaying or analyzing the video
            displayVideoAsset(asset)
        } else {
            showAlert(title: "Error", message: "Video not found.")
        }
    }
    
    private func displayVideoAsset(_ asset: PHAsset) {
        // Request the AVAsset for the PHAsset
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, audioMix, info in
            guard let self = self, let avAsset = avAsset else { return }
            
            DispatchQueue.main.async {
                let playerItem = AVPlayerItem(asset: avAsset)
                let player = AVPlayer(playerItem: playerItem)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    player.play()
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
