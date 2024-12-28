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
extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return Data(bytes: &value, count: MemoryLayout<Self>.size)
    }
}

class AnalyzingViewController: UIViewController {
    
    private var newPresentation: NewPresentation?
    private var assetIdentifier: String?
    
    // 생성자
    init(newPresentation: NewPresentation){
        super.init(nibName: nil, bundle: nil)
        self.newPresentation = newPresentation
        self.assetIdentifier = newPresentation.videoKey
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //var assetIdentifier: String? // 촬영한 비디오 고유 아이디
    var videoAsset: PHAsset? // 비디오 담는 변수
    // AVAudioPlayer instance
    private var audioPlayer: AVAudioPlayer?
    
    
    let waitingLabel: UILabel = {
        let label = UILabel()
        label.text = "열심히 발표를 분석 중이에요!"
        label.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    private let extractAndUploadButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Extract & Upload Audio", for: .normal)
//        button.addTarget(self, action: #selector(extractAndUploadAudio), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor.systemBlue
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        return button
//    }()
//
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
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchVideoAsset()
        
        configureAudioSessionForPlayback()
    }
    
    private func configureAudioSessionForPlayback() {
        let session = AVAudioSession.sharedInstance() // Manages how audio is played/recorded.
        do {
            // .playback ensures the app plays through speakers even if the iPhone is on silent mode
            try session.setCategory(.playback, mode: .default, options: []) // audio can play even if the device is muted.
            try session.setActive(true) // .setActive(true): Makes the session active immediately, finalizing these settings.
        } catch {
            print("Error setting AVAudioSession category: \(error.localizedDescription)")
        }
    }
    
    private func setupUI() {
        
        view.addSubview(waitingLabel)
        view.addSubview(activityIndicator)
        view.addSubview(playAudioButton)
        
        // Layout Extract & Upload Button
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 30),
            
            playAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playAudioButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
        ])
        
    }
    
    private func fetchVideoAsset() {
        guard let identifier = assetIdentifier else {
            showAlert(title: "Error", message: "No video identifier provided.")
            return
        }
        
        // Photos framework가 PHAsset 써서 아이디랑 맞는 어셋 불러옴
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        // 불러온 어셋들 중 첫번째 어셋 근데 어차피 하나만 불러옴
        if let asset = assets.firstObject {
            self.videoAsset = asset
            extractAndUploadAudio()
        } else {
            showAlert(title: "Error", message: "Video not found.")
        }
    }
    
    @objc private func extractAndUploadAudio() {
        guard let asset = videoAsset else {
            showAlert(title: "Error", message: "No video asset available.")
            return
        }
        
        extractAudio(from: asset) { [weak self] data in
            guard let self = self, let wavData = data else {
                self?.showAlert(title: "Error", message: "Failed to extract audio.")
                return
            }
            DispatchQueue.main.async {
                self.playAudioButton.isHidden = false // DEBUG
            }
            self.initializeAudioPlayer(with: wavData) // Initialize AVAudioPlayer for playback
            //self.uploadAudioViaMoya(wavData)
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
    private func uploadAudioViaMoya(_ wavData: Data) {
            guard let presentation = newPresentation else {
                showAlert(title: "Error", message: "No presentation data to send.")
                return
            }
            
            // Moya-based call
            NetworkManager.shared.createPresentation(newPresentation: presentation, wavData: wavData) { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let returnedPresentation):
                        // The server might return updated JSON
                        self.showAlert(title: "Success",
                                       message: "Presentation + audio uploaded!")
                        
                    case .failure(let error):
                        self.showAlert(title: "Upload Error",
                                       message: error.localizedDescription)
                    }
                }
            }
        }
    
    // MARK: - Audio Extraction and Conversion
    private func extractAudio(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
        // 비디오 데이타를 어떻게 불러올건지 설정
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true // Allows fetching from iCloud if needed
        
        // 비디오 어셋을 비동기로 불러옴
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, audioMix, info in
            guard let self = self, let avAsset = avAsset else {
                self?.showAlert(title: "Error", message: "Unable to retrieve AVAsset.")
                completion(nil)
                return
            }
            
            // 영상에서 오디오를 가져오는데 성공하면 wav파일로 변환 시작
            self.convertAVAssetToWav(avAsset) { wavData in
                guard let wavData = wavData else {
                    completion(nil)
                    return
                }
                
                
                // Continue with normal flow...
                completion(wavData)
            }

        }
    }
    
    private func convertAVAssetToWav(_ avAsset: AVAsset, completion: @escaping (Data?) -> Void) {
        // Create an AVAssetReader instance to read audio samples
        // AVAssetReader는 AVAsset으로부터 순차적으로 미디어 데이터를 읽거가 디코딩하는데 쓰임
        guard let assetReader = try? AVAssetReader(asset: avAsset) else {
            showAlert(title: "Error", message: "Unable to create AVAssetReader.")
            completion(nil)
            return
        }
        
        // 오디오 트랙을 가져옴
        guard let audioTrack = avAsset.tracks(withMediaType: .audio).first else {
            showAlert(title: "Error", message: "No audio track found in the video.")
            completion(nil)
            return
        }
        
        // Define the output settings for PCM
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM), //uncompressed audio
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        // AVAssetReaderTrackOutput: 하나의 오디오 트랙을 지정한 설정에 맞춰서 읽는 클래스, 의 인스턴스 생성
        let trackOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        
        if assetReader.canAdd(trackOutput) {
            assetReader.add(trackOutput) // trackOutput에서 데이터를 읽어들임
        } else {
            showAlert(title: "Error", message: "Cannot add track output to AVAssetReader.")
            completion(nil)
            return
        }
        
        // 지정한 설정대로 미디어 데이터를 읽기 시작함
        if assetReader.startReading() {
            var audioData = Data() // A flexible container for binary data
            
            while let sampleBuffer = trackOutput.copyNextSampleBuffer(), // 다음 샘플 버퍼를 가져옴
                  // 버퍼 있음
                  let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) { // 버퍼 가져와서 넣음
                let length = CMBlockBufferGetDataLength(blockBuffer)
                var data = Data(count: length) //This allocates memory to hold the incoming audio bytes.
                
                // Provides a mutable pointer to the raw bytes of the Data object, allowing direct memory manipulation.
                data.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
                    // Copies a specified range of bytes from the blockBuffer into a destination memory location.
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
        //Determines the number of bytes processed per second.
        let byteRate = sampleRate * channels * bitsPerSample / 8
        
        //Specifies the number of bytes for one sample including all channels.
        let blockAlign = channels * bitsPerSample / 8
        
        let totalDataLen = 36 + dataSize // Computes the total size of the WAV file minus the first 8 bytes.
        // The WAV file header is 44 bytes long.
        // totalDataLen represents the size of the file starting after the first 8 bytes (ChunkID and ChunkSize), hence 44 - 8 = 36.
        // Adding dataSize gives the total size needed for the WAV header and audio data.
        
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
