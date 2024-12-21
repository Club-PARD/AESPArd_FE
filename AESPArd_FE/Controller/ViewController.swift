//
//  ViewController.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/16/24.
//

import UIKit

class ViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setTabBar();
    }
    
    func setTabBar() {
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        
        // 서치바 쓰려면 따로 또 루트 등록해줘야 하는 듯
//        let vc2 = UINavigationController(rootViewController: SearchViewController())
//        let vc3 = ComingSoonViewController()
        
        self.viewControllers = [vc1]
        self.tabBar.tintColor = .white
        self.tabBar.backgroundColor = .black
        
        guard let tabBarItems = self.tabBar.items else {return}
        tabBarItems[0].image = UIImage(systemName: "star.fill")
//        tabBarItems[1].image = UIImage(named: "search.png")
//        tabBarItems[2].image = UIImage(named: "coming.png")

        
        tabBarItems[0].title = "Home"
//        tabBarItems[1].title = "Search"
//        tabBarItems[2].title = "Coming Soon"

        
    }
}
