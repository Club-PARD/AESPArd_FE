//
//  SplashViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/28/24.
//

import UIKit
import AVKit

class SplashViewController: UIViewController {

    var player: AVPlayer? // AVPlayer 변수 선언

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoBackground() // 비디오 재생 함수 호출
        setupButton() // 버튼 추가 함수 호출
        view.backgroundColor = UIColor(red: 44/255, green: 101/255, blue: 253/255, alpha: 1.0)
    }

    // 비디오 배경 설정
    private func setupVideoBackground() {
        // 1. MP4 파일 경로 설정
        guard let path = Bundle.main.path(forResource: "SplashVideo", ofType: "mp4") else {
            print("비디오 파일을 찾을 수 없습니다.")
            return
        }
        print("비디오 파일 경로: \(path)")
        let url = URL(fileURLWithPath: path)

        // 2. AVPlayer 생성
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)

        // 3. 크기와 화면 맞춤 설정
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)

        // 4. 비디오 재생
        player?.play()
    }

    // 버튼 추가 설정
    private func setupButton() {
        let button = UIButton(type: .system)
        button.setTitle("apple로 로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Pretendard-SemiBold", size: 20)
        button.backgroundColor = .black
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)

        // 버튼 위치 설정
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.widthAnchor.constraint(equalToConstant: 358),
            button.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc private func goToLogin() {
        player?.pause() // 비디오 정지
        
        // 디졸브 애니메이션 효과
        let VC = ViewController() // 이동할 뷰 컨트롤러 인스턴스 생성
        VC.modalPresentationStyle = .fullScreen // 전체 화면으로 표시
        VC.modalTransitionStyle = .crossDissolve // 디졸브 효과 설정
        
        present(VC, animated: true, completion: nil)
    }

}
