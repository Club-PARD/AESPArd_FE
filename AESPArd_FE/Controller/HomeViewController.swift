//
//  HomeController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/21/24.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record Video", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 160)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }
    
    @objc private func startButtonTapped() {
        let cameraVC = CameraViewController()
        navigationController?.pushViewController(cameraVC, animated: true)
    }
}
