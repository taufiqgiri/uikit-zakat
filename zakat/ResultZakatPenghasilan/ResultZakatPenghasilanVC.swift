//
//  ResultZakatPenghasilanVC.swift
//  zakat
//
//  Created by Taufiq Ichwanusofa on 09/05/22.
//

import UIKit

class ResultZakatPenghasilanVC: UIViewController {
    @IBOutlet weak var labelExplanation: UILabel!
    @IBOutlet weak var btnHitungLagi: UIButton!
    @IBOutlet weak var labelFee: UILabel!
    @IBOutlet weak var labelFreeFee: UILabel!
    
    var zakatFee: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapHitungLagi = UITapGestureRecognizer(target: self, action: #selector(goBack))
        btnHitungLagi.addGestureRecognizer(tapHitungLagi)
        
        guard let customButtonFont = UIFont(name: "Chalkboard SE", size: 14) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        
        guard let customBodyFont = UIFont(name: "Chalkboard SE", size: 30) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        
        labelFreeFee.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: customBodyFont)
        btnHitungLagi.titleLabel?.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customButtonFont)
        
        btnHitungLagi.titleLabel?.adjustsFontForContentSizeCategory = true
        labelFreeFee.adjustsFontForContentSizeCategory = true
        
        if zakatFee! > 0 {
            labelFreeFee.isHidden = true
            labelFee.text = "Rp \(zakatFee?.formattedWithSeparator ?? "0")"
            labelExplanation.font = UIFont.preferredFont(forTextStyle: .title1)
            labelFee.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            labelExplanation.adjustsFontForContentSizeCategory = true
            labelFee.adjustsFontForContentSizeCategory = true
        } else {
            labelExplanation.isHidden = true
            labelFee.isHidden = true
            labelFreeFee.font = UIFont.preferredFont(forTextStyle: .largeTitle)
            labelFreeFee.adjustsFontForContentSizeCategory = true
        }
    }
    
    @objc func goBack() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
