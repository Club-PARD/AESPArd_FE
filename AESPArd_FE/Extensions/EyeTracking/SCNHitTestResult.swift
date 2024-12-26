//
//  SCNHitTestResult.swift
//  AESPArd_FE
//
//  Created by KimDogyung on 12/23/24.
//

import UIKit
import SceneKit
//import DeviceKit



extension SCNHitTestResult {
    var screenPosition: CGPoint {
        let physicalIpadSize = CGSize(width: 0.062 / 2 , height: 0.135 / 2)
        let screenResolution = UIScreen.main.bounds.size
        
        let screenX = CGFloat(localCoordinates.x) / physicalIpadSize.width * screenResolution.width
        let screenY = CGFloat(localCoordinates.y) / physicalIpadSize.height * screenResolution.height
        
        return CGPoint(x: screenX, y: screenY)
    }
}




//extension UIScreen {
//    /// Returns the PPI for the current device
//    var ppi: CGFloat {
//        let device = Device.current
//
//        switch device {
//        // iPhones (Retina displays)
//        case .iPhone12:
//            return 264.0
//            
//        case .iPhoneSE, .iPhone6, .iPhone6s, .iPhone7, .iPhone8, .iPhoneX, .iPhone11, .iPhone13, .iPhone14:
//            return 460.0
//        case .iPhone14Pro, .iPhone14ProMax, .iPhone13Pro, .iPhone13ProMax, .iPhone12Pro, .iPhone12ProMax:
//            return 458.0
//
//        // iPads
//        case .iPadMini, .iPadMini4, .iPadMini5, .iPadMini6, .iPadAir11M2:
//            return 326.0
//        case .iPadPro12Inch:
//            return 264.0
//
//        // Default case
//        default:
//            return 264.0 // Fallback to a standard PPI for iPads
//        }
//    }
//}
