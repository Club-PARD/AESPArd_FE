//
//  AnalysisVie.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/26/24.
//


import UIKit
import Photos
import AVFoundation

// MARK: - FixedWidthInteger Extension
// This extension adds a computed property to convert integers to Data in little endian format.
// It must be declared at the top level, outside of any classes or other extensions.
extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}

class AnalyzingViewController: UIViewController {
    var assetIdentifier: String?
    var videoAsset: PHAsset?
    
    // UI Elements
    private let extractAndUploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Extract & Upload Audio", for: .normal)
        button.addTarget(self, action: #selector(extractAndUploadAudio), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let playAudioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Audio", for: .normal)
        button.addTarget(self, action: #selector(playAudioButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isHidden = true // Hidden until audio is extracted
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // AVAudioPlayer instance
    private var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        fetchVideoAsset()
    }
    
    private func setupUI() {
        // Add buttons and activity indicator to the view
        view.addSubview(extractAndUploadButton)
        view.addSubview(playAudioButton)
        view.addSubview(activityIndicator)
        
        // Layout Extract & Upload Button
        NSLayoutConstraint.activate([
            extractAndUploadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            extractAndUploadButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            extractAndUploadButton.heightAnchor.constraint(equalToConstant: 60),
            extractAndUploadButton.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        // Layout Play Audio Button
        NSLayoutConstraint.activate([
            playAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAudioButton.topAnchor.constraint(equalTo: extractAndUploadButton.bottomAnchor, constant: 20),
            playAudioButton.heightAnchor.constraint(equalToConstant: 60),
            playAudioButton.widthAnchor.constraint(equalToConstant: 250)
        ])
        
        // Layout Activity Indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: playAudioButton.bottomAnchor, constant: 30)
        ])
    }
    
    private func fetchVideoAsset() {
        guard let identifier = assetIdentifier else {
            showAlert(title: "Error", message: "No video identifier provided.")
            return
        }
        
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        if let asset = assets.firstObject {
            self.videoAsset = asset
            // Optionally, display the video or perform other actions
        } else {
            showAlert(title: "Error", message: "Video not found.")
        }
    }
    
    @objc private func extractAndUploadAudio() {
        guard let asset = videoAsset else {
            showAlert(title: "Error", message: "No video asset available.")
            return
        }
        extractAndUploadButton.isEnabled = false
        playAudioButton.isHidden = true
        activityIndicator.startAnimating()
        extractAudio(from: asset) { [weak self] data in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.extractAndUploadButton.isEnabled = true
            }
            guard let self = self, let wavData = data else {
                self?.showAlert(title: "Error", message: "Failed to extract audio.")
                return
            }
            DispatchQueue.main.async {
                self.playAudioButton.isHidden = false
            }
            self.initializeAudioPlayer(with: wavData) // Initialize AVAudioPlayer for playback
            self.uploadAudioData(wavData)
        }
    }
    
    @objc private func playAudioButtonTapped() {
        guard let wavData = audioPlayer?.data else {
            showAlert(title: "Error", message: "No audio data available to play.")
            return
        }
        playAudio(from: wavData)
    }
    
    private func initializeAudioPlayer(with data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            // Optionally, autoplay for debugging
            // audioPlayer?.play()
        } catch {
            showAlert(title: "Playback Error", message: error.localizedDescription)
        }
    }
    
    private func playAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            // Update Play button state
            DispatchQueue.main.async {
                self.playAudioButton.setTitle("Playing...", for: .normal)
                self.playAudioButton.isEnabled = false
            }
        } catch {
            showAlert(title: "Playback Error", message: error.localizedDescription)
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
    
    // MARK: - Audio Upload
    private func uploadAudioData(_ data: Data) {
        // Define your server URL
        guard let url = URL(string: "https://yourserver.com/upload") else {
            showAlert(title: "Error", message: "Invalid server URL.")
            return
        }
        
        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Define the boundary for multipart/form-data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Construct the HTTP body
        var body = Data()
        
        // Add the audio file data
        let filename = "extractedAudio.wav"
        let mimeType = "audio/wav"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close the multipart form
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the body
        request.httpBody = body
        
        // Optionally, set the Content-Length
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        // Create the URLSession task
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] responseData, response, error in
            if let error = error {
                self?.showAlert(title: "Upload Failed", message: error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self?.showAlert(title: "Upload Failed", message: "Invalid server response.")
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                self?.showAlert(title: "Success", message: "Audio uploaded successfully!")
            } else {
                let statusCode = httpResponse.statusCode
                let message = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                self?.showAlert(title: "Upload Failed", message: "Server responded with status code \(statusCode): \(message)")
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: - Audio Extraction and Conversion
    private func extractAudio(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true // Allows fetching from iCloud if needed
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, audioMix, info in
            guard let self = self, let avAsset = avAsset else {
                self?.showAlert(title: "Error", message: "Unable to retrieve AVAsset.")
                completion(nil)
                return
            }
            
            // Proceed to extract audio
            self.convertAVAssetToWav(avAsset) { wavData in
                completion(wavData)
            }
        }
    }
    
    private func convertAVAssetToWav(_ avAsset: AVAsset, completion: @escaping (Data?) -> Void) {
        // Create an AVAssetReader to read audio samples
        guard let assetReader = try? AVAssetReader(asset: avAsset) else {
            showAlert(title: "Error", message: "Unable to create AVAssetReader.")
            completion(nil)
            return
        }
        
        // Get the audio track
        guard let audioTrack = avAsset.tracks(withMediaType: .audio).first else {
            showAlert(title: "Error", message: "No audio track found in the video.")
            completion(nil)
            return
        }
        
        // Define the output settings for PCM
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        
        if assetReader.canAdd(trackOutput) {
            assetReader.add(trackOutput)
        } else {
            showAlert(title: "Error", message: "Cannot add track output to AVAssetReader.")
            completion(nil)
            return
        }
        
        // Start reading
        if assetReader.startReading() {
            var audioData = Data()
            
            while let sampleBuffer = trackOutput.copyNextSampleBuffer(),
                  let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length)
                
                data.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
                    CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
                }
                
                audioData.append(data)
            }
            
            // Stop reading
            assetReader.cancelReading()
            
            // Create WAV header
            guard let wavHeader = createWavHeader(sampleRate: 44100, channels: 2, bitsPerSample: 16, dataSize: audioData.count) else {
                showAlert(title: "Error", message: "Failed to create WAV header.")
                completion(nil)
                return
            }
            
            // Combine header and audio data
            var wavData = Data()
            wavData.append(wavHeader)
            wavData.append(audioData)
            
            completion(wavData)
        } else {
            showAlert(title: "Error", message: "Failed to start reading audio track.")
            completion(nil)
        }
    }
    
    private func createWavHeader(sampleRate: Int, channels: Int, bitsPerSample: Int, dataSize: Int) -> Data? {
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8
        let totalDataLen = 36 + dataSize
        
        var header = Data(capacity: 44)
        
        // RIFF header
        header.append(contentsOf: "RIFF".utf8) // ChunkID
        header.append(UInt32(totalDataLen).littleEndianData) // ChunkSize
        header.append(contentsOf: "WAVE".utf8) // Format
        
        // fmt subchunk
        header.append(contentsOf: "fmt ".utf8) // Subchunk1ID
        header.append(UInt32(16).littleEndianData) // Subchunk1Size (16 for PCM)
        header.append(UInt16(1).littleEndianData) // AudioFormat (1 for PCM)
        header.append(UInt16(channels).littleEndianData) // NumChannels
        header.append(UInt32(sampleRate).littleEndianData) // SampleRate
        header.append(UInt32(byteRate).littleEndianData) // ByteRate
        header.append(UInt16(blockAlign).littleEndianData) // BlockAlign
        header.append(UInt16(bitsPerSample).littleEndianData) // BitsPerSample
        
        // data subchunk
        header.append(contentsOf: "data".utf8) // Subchunk2ID
        header.append(UInt32(dataSize).littleEndianData) // Subchunk2Size
        
        return header
    }
}

// MARK: - AVAudioPlayerDelegate
extension AnalyzingViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            showAlert(title: "Playback Finished", message: "Audio playback completed successfully.")
        } else {
            showAlert(title: "Playback Error", message: "Audio playback did not finish successfully.")
        }
        
        // Reset Play button state
        DispatchQueue.main.async {
            self.playAudioButton.setTitle("Play Audio", for: .normal)
            self.playAudioButton.isEnabled = true
        }
        
        // Release the audio player
        audioPlayer = nil
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            showAlert(title: "Playback Decode Error", message: error.localizedDescription)
        }
        
        // Reset Play button state
        DispatchQueue.main.async {
            self.playAudioButton.setTitle("Play Audio", for: .normal)
            self.playAudioButton.isEnabled = true
        }
        
        // Release the audio player
        audioPlayer = nil
    }
}
