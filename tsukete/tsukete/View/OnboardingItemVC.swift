//
//  OnboardingItemVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit

class OnboardingItemVC: UIViewController {
    
    var explainTitle = "Tsuketeの使い方"
    var mainText = ""
    var topImage: UIImage? = UIImage()
    
    @IBOutlet weak var logoImageView: UIImageView! {
        didSet {
            self.logoImageView.image = UIImage(named: "tsuketeLogo")
        }
    }
    
    @IBOutlet private weak var topImageView: UIImageView!
    
    @IBOutlet private weak var mainTitleLabel: UILabel! {
        didSet {
            mainTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var explainLabel: UILabel! {
        didSet {
            explainLabel.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        explainLabel.text = explainTitle
        topImageView.image = topImage
        mainTitleLabel.text = mainText
    }

}
