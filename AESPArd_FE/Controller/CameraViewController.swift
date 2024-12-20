//
//  CameraViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/20/24.
//

import UIKit
import AVFoundation
import Photos
import Vision

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var captureSession: AVCaptureSession!
    private var videoDeviceInput: AVCaptureDeviceInput!
    private var movieFileOutput: AVCaptureMovieFileOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
  
    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("●", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // Check permission
        checkCameraAuthorization()
    }
    
    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupSession()
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        case .authorized:
            setupSession()
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(title: "Camera Access Needed",
                                      message: "Please enable camera access in Settings.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No back camera available.")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                self.videoDeviceInput = cameraInput
            } else {
                print("Unable to add camera input.")
                return
            }
        } catch {
            print("Error: \(error)")
            return
        }
        
        let movieOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
            movieFileOutput = movieOutput
        }
        
//        guard let audioDevice = AVCaptureDevice.default(for: .audio),
//              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
//              captureSession.canAddInput(audioInput) else {
//            print("Cannot add audio input")
//            return
//        }
//        captureSession.addInput(audioInput)
        
        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        
        // Bring shutter button to front
        view.addSubview(shutterButton)
        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shutterButton.widthAnchor.constraint(equalToConstant: 80),
            shutterButton.heightAnchor.constraint(equalToConstant: 80),
            
            
        ])
        
        shutterButton.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        
        captureSession.startRunning()
    }
    
    @objc private func shutterButtonTapped() {
        guard let movieFileOutput = self.movieFileOutput else { return }
        
        if !isRecording {
            // Start recording
            let outputDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + ".mov"
            let outputURL = outputDirectory.appendingPathComponent(fileName)
            
            movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
            isRecording = true
            
            DispatchQueue.main.async {
                self.shutterButton.setTitle("■", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
            }
        } else {
            // Stop recording
            movieFileOutput.stopRecording()
            isRecording = false
            
            DispatchQueue.main.async {
                self.shutterButton.setTitle("●", for: .normal)
                self.shutterButton.setTitleColor(.red, for: .normal)
            }
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        
        if let error = error {
            print("Error recording movie: \(error.localizedDescription)")
            return
        }
        
        // Save the recorded video to the photo library
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Photo Library access not granted.")
                return
            }
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func videoSaved(_ videoPath: String,
                                  didFinishSavingWithError error: Error?,
                                  contextInfo: Any?) {
        DispatchQueue.main.async {
            if let error = error {
                let alert = UIAlertController(title: "Save Error",
                                              message: "Video could not be saved: \(error.localizedDescription)",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "Saved",
                                              message: "Your video has been saved to Photos.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
