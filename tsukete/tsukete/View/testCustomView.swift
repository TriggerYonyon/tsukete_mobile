//
//  testCustomView.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/13.
//

import UIKit

//こっちの方が本番のやつ

enum isSelected {
    case selected
    case normal
}


protocol cardViewDelegate {
    func requestButtonEvent()
    func hartButtonEvent()
}

class testCustomView: UIView {
    @IBOutlet var customView: UIView!
    
    @IBOutlet weak var imageStackview: UIStackView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    @IBOutlet weak var requestButton: UIButton! {
        didSet {
            setRequestButton()
        }
    }
    @IBOutlet weak var hartButton: UIButton! {
        didSet {
            hartButton.setTitle("", for: .normal)
            setHartButton()
        }
    }
    
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var openTime: UILabel!
    @IBOutlet weak var closeTime: UILabel!
    @IBOutlet weak var vacancyState: UILabel!
    
    
    public var delegate: cardViewDelegate?
    public var hartButtonState: isSelected = .normal
    public var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.5, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = .cubic
        return bounceAnimation
    }()
    
    private let xibName = "testCustomView"
    var mainTitle = ""
    var vacancyTitle = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
        
        customView.frame = self.bounds
        customView.layer.cornerRadius = 15
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        customView.backgroundColor = .white
        self.addSubview(customView)
    }
    
    private func setRequestButton() {
        requestButton.layer.cornerRadius = 15
        requestButton.backgroundColor = UIColor(rgb: 0xFFBC42)
        requestButton.setTitle("¥ 設置リクエスト", for: .normal)
        requestButton.setTitleColor(.black, for: .normal)
    }
    
    public func setHartButton() {
        if hartButtonState == .normal {
            print("it is normal")
            let normalImage = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
            hartButton.setImage(normalImage, for: .normal)
        } else {
            print("it is selected")
            let selectedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
            hartButton.setImage(selectedImage, for: .normal)
        }
               
        hartButton.tintColor = .systemRed
    }
    
    // with model: PlaceModel
    public func configure(state requestState: Bool) {
//        if !model.isEmpty {
//            // Imageを3つに絞る
//            // ⚠️途中の段階:Image URL処理をまだ
//            cardView.image1.image = imageData[0]
//            cardView.image2.image = imageData[1]
//            cardView.image3.image = imageData[2]
//        } else {
//            cardView.image1.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//            cardView.image2.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//            cardView.image3.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//        }
        
        if requestState == false {
            restaurantName.text = "Yonyon食堂"
            openTime.text = "Open: 10:00AM"
            closeTime.text = "Close: 20:00PM"
            vacancyState.text = "カメラを設置していません"
            vacancyState.textColor = .lightGray
            vacancyState.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        } else {
            restaurantName.text = "Yonyon食堂"
            openTime.text = "Open: 10:00AM"
            closeTime.text = "Close: 20:00PM"
            vacancyState.text = "空きあり"
            vacancyState.textColor = UIColor(rgb: 0x06B3EA)
            vacancyState.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            requestButton.isHidden = true
        }
    }
    
    @IBAction func requestButtonTapped(_ sender: Any) {
        self.delegate?.requestButtonEvent()
    }
    
    // 名前間違えた hear -> hartに変更する予定
    @IBAction func hearButtonTapped(_ sender: Any) {
        self.delegate?.hartButtonEvent()
    }
    
    

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: CGFloat(a) / 255.0
        )
    }
    
    convenience init(rgb: Int) {
        self.init(red: (rgb >> 16) & 0xFF,
                  green: (rgb >> 8) & 0xFF,
                  blue: rgb & 0xFF
        )
    }
    
    convenience init(argb: Int) {
        self.init(red: (argb >> 16) & 0xFF,
                  green: (argb >> 8) & 0xFF,
                  blue: argb & 0xFF,
                  a: (argb >> 24) & 0xFF
        )
    }
}
