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
   
    
    // MARK: - 이전 뷰컨에서 받아오는 변수값들
    private var newPresentation: NewPresentation?
    private var newPractice: NewPractice?
    private var assetIdentifier: String?
    private var audioData: Data? // Stores the extracted audio data
    
    private var isCreatingNewPresentation: Bool?
    private var isCreatingNewPractice: Bool?
    
    // MARK: - 생성자
    
    // 새발표용
    init(newPresentation: NewPresentation){
        super.init(nibName: nil, bundle: nil)
        self.newPresentation = newPresentation
        self.assetIdentifier = newPresentation.videoKey
        isCreatingNewPresentation = true
        isCreatingNewPractice = false
        debugPrint(newPresentation)
    }
    
    // 기존 발표의 새 연습용
    init(newPractice: NewPractice, assetIdentifier: String){
        super.init(nibName: nil, bundle: nil)
        self.newPractice = newPractice
        self.assetIdentifier = assetIdentifier
        isCreatingNewPresentation = false
        isCreatingNewPractice = true
        //debugPrint(newPresentation)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - 이 페이지에서 쓰이는 변수들
    
    var videoAsset: PHAsset? // 비디오 담는 변수
    // AVAudioPlayer instance
    private var audioPlayer: AVAudioPlayer?
    
    
    // MARK: - UI
    
    let waitingLabel: UILabel = {
        let label = UILabel()
        label.text = "리포트를 생성 중입니다"
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
//    private let playAudioButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Play Audio", for: .normal)
//        button.addTarget(self, action: #selector(playAudioButtonTapped), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.backgroundColor = UIColor.systemGreen
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        button.isHidden = true // Hidden until audio is extracted
//        return button
//    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private func setupUI() {
        
        view.addSubview(waitingLabel)
        view.addSubview(activityIndicator)
        view.backgroundColor = .clear
//        view.addSubview(playAudioButton)
        
        // Layout Extract & Upload Button
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            waitingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 50),
            
//            playAudioButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            playAudioButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
        ])
        
    }
    
    // MARK: - 생성주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fetchVideoAsset()
        
        //configureAudioSessionForPlayback()
    }
    
//    private func configureAudioSessionForPlayback() {
//        let session = AVAudioSession.sharedInstance() // Manages how audio is played/recorded.
//        do {
//            // .playback ensures the app plays through speakers even if the iPhone is on silent mode
//            try session.setCategory(.playback, mode: .default, options: []) // audio can play even if the device is muted.
//            try session.setActive(true) // .setActive(true): Makes the session active immediately, finalizing these settings.
//        } catch {
//            print("Error setting AVAudioSession category: \(error.localizedDescription)")
//        }
//    }
    
    
    // MARK: - 함수들
    
    
    // 갤러리에 저장된 비디오를 가져옴
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
            extractAndUpload()
        } else {
            showAlert(title: "Error", message: "Video not found.")
        }
    }
    

    
    // 비디오에서 오디오로 변한하는 함수를 실행하고 결과값에 따라 서버로 전송 혹은 에러 처리하는 함수
    private func extractAndUpload() {
        guard let asset = videoAsset else {
            showAlert(title: "Error", message: "No video asset available.")
            return
        }
        
        extractAudio(from: asset) { [weak self] (data, isSilent) in
            guard let self = self, let wavData = data else {
                self?.showAlert(title: "Error", message: "Failed to extract audio.")
                return
            }
            
            if isSilent {
                let alert = UIAlertController(title: "소리 없음", message: "발표가 녹음되지 않았습니다. 스크린 녹화와 마이크 녹음 모두 허용해주세요", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    //self.goBackToHome()
                    // 여기서 홈뷰컨으로 돌아가게 해야함
                }))
                self.present(alert, animated: true)
            } else {
//                self.initializeAudioPlayer(with: wavData) // Initialize AVAudioPlayer for playback
                //self.uploadAudioViaMoya(wavData)
                //uploadOnlyAudio(wavData)
            }
        }
    }
    
    
    
//    @objc private func playAudioButtonTapped() {
//        guard let wavData = audioPlayer?.data else {
//            showAlert(title: "Error", message: "No audio data available to play.")
//            return
//        }
//        playAudio(from: wavData)
//    }
    
//    private func initializeAudioPlayer(with data: Data) {
//        do {
//            audioPlayer = try AVAudioPlayer(data: data)
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//            // Optionally, autoplay for debugging
//            audioPlayer?.play()
//        } catch {
//            showAlert(title: "Playback Error", message: error.localizedDescription)
//        }
//    }
    
    
    private func extractAudio(from asset: PHAsset, completion: @escaping (Data?, Bool) -> Void) {
        // 비디오 데이타를 어떻게 불러올건지 설정
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true // Allows fetching from iCloud if needed
        
        // 비디오 어셋을 비동기로 불러옴
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] avAsset, audioMix, info in
            guard let self = self, let avAsset = avAsset else {
                
                DispatchQueue.main.async {
                            self?.showAlert(title: "Error", message: "Unable to retrieve AVAsset.")
                }
                completion(nil, true)
                return
            }
            
            
            // 영상에서 오디오를 가져오는데 성공하면 wav파일로 변환 시작
            self.convertAVAssetToWav(avAsset) { wavData, isSilent in
                DispatchQueue.main.async {
                    guard let wavData = wavData else {
                        completion(nil, true)
                        return
                    }
                    // DEBUG: Log or check the file size here
                    //debugPrint("Extracted WAV data size: \(wavData.count) bytes")
                    
                    completion(wavData, isSilent)
                }
            }

        }
    }
    
    private func convertAVAssetToWav(_ avAsset: AVAsset, completion: @escaping (Data?, Bool) -> Void) {
        // Create an AVAssetReader instance to read audio samples
        // AVAssetReader는 AVAsset으로부터 순차적으로 미디어 데이터를 읽거가 디코딩하는데 쓰임
        guard let assetReader = try? AVAssetReader(asset: avAsset) else {
            showAlert(title: "Error", message: "Unable to create AVAssetReader.")
            completion(nil, true)
            return
        }
        
        // 오디오 트랙을 가져옴
        guard let audioTrack = avAsset.tracks(withMediaType: .audio).first else {
            showAlert(title: "Error", message: "No audio track found in the video.")
            completion(nil, true)
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
            completion(nil, true)
            return
        }
        
        // 1) We'll define a threshold for "silence":
        let silenceThreshold: Int16 = 200 // 이게 무음 오디오인지 판단하는 기준. 이것보다 크면 무음 아님
        var noSilenceCount = 0 // 소리가 있는 오디오면 카운트업 됨
        
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
                
//                 2) Check the amplitude in this chunk
//                    We'll interpret the chunk as an array of 16-bit samples
//                 오디오 파일에 진짜 사운드가 들어이있는지 확인
                let sampleCount = length / MemoryLayout<Int16>.size
                data.withUnsafeBytes { (samples: UnsafeRawBufferPointer) in
                    let int16Pointer = samples.bindMemory(to: Int16.self)
                    
                    for i in 0..<sampleCount {
                        let sample = int16Pointer[i]
                        // If any sample exceeds our threshold, it's not silent
                        if abs(sample) > silenceThreshold {
                            noSilenceCount += 1
                            break
                        }
                    }
                }
                
                
                audioData.append(data)
            }
            
            // Stop reading
            assetReader.cancelReading()
            
            // WAV 파일의 헤더 생성
            guard let wavHeader = createWavHeader(sampleRate: 44100, channels: 2, bitsPerSample: 16, dataSize: audioData.count) else {
                showAlert(title: "Error", message: "Failed to create WAV header.")
                completion(nil, true)
                return
            }
            
            // 헤더랑 오디오 데이터 합치기
            var wavData = Data()
            wavData.append(wavHeader)
            wavData.append(audioData)
            
            // 무음파일 여부에 따른 리턴
            if(noSilenceCount > 0) {
                completion(wavData, false)
            } else {
                completion(wavData, true)
            }
            
        } else {
            showAlert(title: "Error", message: "Failed to start reading audio track.")
            completion(nil, true)
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
    
    
    // MARK: - 서버 전달 함수들
    
    
    // 오디오만 따로 전달
    private func uploadAudio(_ wavData: Data) {
        // Create the upload
        NetworkManager.shared.uploadAudio(wavData: wavData) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.success {
                        self.showAlert(title: "Success", message: response.message)
                    } else {
                        self.showAlert(title: "Upload Failed", message: "Server responded with an error.")
                    }
                    
                case .failure(let error):
                    self.showAlert(title: "Upload Error", message: error.localizedDescription)
                }
            }
        }
    }
    
//    private func uploadPracticeAndAudio(_ newPractice: NewPractice, _ wavData: Data){
//        NetworkManager.shared.uploadPracticeAndAudio(newPractice: newPractice, wavData: wavData, completion: <#T##(Result<UploadAudioResponse, any Error>) -> Void#>)
//    }
    
//    private func playAudio(from data: Data) {
//        do {
//            audioPlayer = try AVAudioPlayer(data: data)
//            audioPlayer?.delegate = self
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.play()
//            
//            // Update Play button state
//            DispatchQueue.main.async {
//                self.playAudioButton.setTitle("Playing...", for: .normal)
//                self.playAudioButton.isEnabled = false
//            }
//        } catch {
//            showAlert(title: "Playback Error", message: error.localizedDescription)
//        }
//    }
    
    
    // MARK: - 기타 함수
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    
    // MARK: - 수정 필요
//    private func goBackToHome() {
//        // 1) Dismiss self
//        self.dismiss(animated: true) { [weak self] in
//            // 2) Switch to the Home tab
//            guard let self = self else { return }
//
//            // Access the window's rootViewController (UITabBarController)
//            if let tabBar = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
//                // Home is presumably at index 0
//                tabBar.selectedIndex = 0
//
//                // 3) If HomeViewController is in a navigation stack, pop it to root
//                if let nav = tabBar.viewControllers?.first as? UINavigationController {
//                    nav.popToRootViewController(animated: false)
//                }
//            }
//        }
//    }
    
}

// MARK: - AVAudioPlayerDelegate
//extension AnalyzingViewController: AVAudioPlayerDelegate {
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            showAlert(title: "Playback Finished", message: "Audio playback completed successfully.")
//        } else {
//            showAlert(title: "Playback Error", message: "Audio playback did not finish successfully.")
//        }
//        
//        // Reset Play button state
//        DispatchQueue.main.async {
//            self.playAudioButton.setTitle("Play Audio", for: .normal)
//            self.playAudioButton.isEnabled = true
//        }
//        
//        // Release the audio player
//        audioPlayer = nil
//    }
//    
//    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
//        if let error = error {
//            showAlert(title: "Playback Decode Error", message: error.localizedDescription)
//        }
//        
//        // Reset Play button state
//        DispatchQueue.main.async {
//            self.playAudioButton.setTitle("Play Audio", for: .normal)
//            self.playAudioButton.isEnabled = true
//        }
//        
//        // Release the audio player
//        audioPlayer = nil
//    }
//}
