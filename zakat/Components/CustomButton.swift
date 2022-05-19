//
//  File.swift
//  zakat
//
//  Created by Taufiq Ichwanusofa on 18/05/22.
//

import Foundation
import UIKit

class CustomButton : UIButton {
    var myHighlighted : Bool = false
    
    override var isHighlighted: Bool {
        get {
            return myHighlighted
        }
        
        set {
            myHighlighted = newValue
            if myHighlighted {
                self.configuration!.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    // We only want to change the font, but we could change other properties here too.
                    outgoing.font = UIFont(name: "Chalkboard SE", size: 14)
                    return outgoing
                }
                self.configuration?.baseBackgroundColor = UIColorFromRGB(0x4f8c57)
            } else {
                self.configuration?.baseBackgroundColor = UIColorFromRGB(0x519259)
            }
        }
    }
    
    func UIColorFromRGB(_ rgbValue: Int) -> UIColor! {
        return UIColor(
            red: CGFloat((Float((rgbValue & 0xff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x00ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x0000ff) >> 0)) / 255.0),
            alpha: 1.0)
    }
}
