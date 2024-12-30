//
//  SCNHitTestResult.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/23/24.
//

import UIKit
import SceneKit


extension SCNHitTestResult {
    var screenPosition: CGPoint {
        let physicalIpadSize = CGSize(width: 0.062 / 2 , height: 0.135 / 2)
        let screenResolution = UIScreen.main.bounds.size
        
        let screenX = CGFloat(localCoordinates.x) / physicalIpadSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalIpadSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}



