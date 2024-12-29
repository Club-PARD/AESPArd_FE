//
//  SplashViewController.swift
//  AESPArd_FE
//
//  Created by 김도원 on 12/28/24.
//

import UIKit
import AVKit
import AuthenticationServices

class SplashViewController: UIViewController {

    var player: AVPlayer? // AVPlayer 변수 선언

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoBackground() // 비디오 재생 함수 호출
        checkAppleIDState() // 로그인 상태 확인
        view.backgroundColor = UIColor(red: 44/255, green: 101/255, blue: 253/255, alpha: 1.0)
    }

    // 비디오 배경 설정
    private func setupVideoBackground() {
        guard let path = Bundle.main.path(forResource: "SplashVideo", ofType: "mp4") else {
            print("비디오 파일을 찾을 수 없습니다.")
            return
        }
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        player?.play()
    }

    // 로그인 상태 확인
    private func checkAppleIDState() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: "appleUserId") else {
            setupButton()
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) { [weak self] (credentialState, error) in
            guard let self = self else { return }
            switch credentialState {
            case .authorized:
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.moveToNextView()
                }
            case .revoked, .notFound:
                DispatchQueue.main.async {
                    self.setupButton()
                }
            default:
                break
            }
        }
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
        player?.pause()
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // 다음 화면으로 이동
    private func moveToNextView() {
        player?.pause()
        let VC = ViewController()
        VC.modalPresentationStyle = .fullScreen
        VC.modalTransitionStyle = .crossDissolve
        present(VC, animated: true, completion: nil)
    }

    // UserInfo 저장 메서드
    private func saveUserInfo(_ userInfo: UserInfo) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(userInfo) {
            UserDefaults.standard.set(encodedData, forKey: "userInfo")
            print("UserInfo 저장 완료")
        } else {
            print("UserInfo 저장 실패")
        }
    }
}

// 애플 로그인 처리
extension SplashViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            UserDefaults.standard.set(userIdentifier, forKey: "appleUserId")

            let firstName = appleIDCredential.fullName?.givenName ?? "없음"
            let lastName = appleIDCredential.fullName?.familyName ?? "없음"
            let email = appleIDCredential.email ?? "정보 없음"
            let authorizationCode = String(data: appleIDCredential.authorizationCode ?? Data(), encoding: .utf8) ?? "코드 없음"
            let identityToken = String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "토큰 없음"

            let userInfo = UserInfo(
                userID: userIdentifier,
                firstName: firstName,
                lastName: lastName,
                email: email,
                authorizationCode: authorizationCode,
                identityToken: identityToken
            )

            print("UserInfo 저장됨: \(userInfo)")
            saveUserInfo(userInfo)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.moveToNextView()
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("애플 로그인 실패: \(error.localizedDescription)")
    }
}

// 애플 로그인 화면 표시
extension SplashViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
