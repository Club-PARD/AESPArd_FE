//
//  VideoPlayerController.swift
//  AESPArd_FE
//
//  Created by 이유현 on 12/20/24.
//

import UIKit
import AVKit

class VideoPlayerController: UIViewController {
    
    var videoURL: URL? // 동영상 URL을 전달받을 프로퍼티
    
    //비디오 플레이어 Controller
    private lazy var playerController: AVPlayerViewController = {
        let player = AVPlayer(url: videoURL!)
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
    }
    
    
    func setUI(){
        //전달 받은 videoURL이 없는 경우 처리
        guard let videoURL = videoURL else {
            print("No video URL provided.")
            return
        }
        
        // AVPlayerViewController를 현재 화면에 추가
        addChild(playerController)
        playerController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerController.view)
        playerController.didMove(toParent: self)
        
        // 동영상 자동 재생
        playerController.player?.play()
        
        // Auto Layout으로 크기 조절
        NSLayoutConstraint.activate([
            playerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playerController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            playerController.view.heightAnchor.constraint(equalToConstant: 300)
        ])
    
    }
}
