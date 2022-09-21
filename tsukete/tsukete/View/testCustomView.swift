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

enum isRequested {
    case requested
    case normal
}


protocol cardViewDelegate {
    func requestButtonEvent()
    func hartButtonEvent()
}

// default値を設定しないと、label label label...などが表示される

class testCustomView: UIView {
    @IBOutlet var customView: UIView!
    
    @IBOutlet weak var imageStackview: UIStackView!
    @IBOutlet weak var image1: UIImageView! {
        didSet {
            // alwaysOriginalをすると、色を無視できるようになる
            image1.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
    }
    @IBOutlet weak var image2: UIImageView! {
        didSet {
            image2.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
    }
    @IBOutlet weak var image3: UIImageView! {
        didSet {
            image3.image = UIImage(systemName: "photo")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        }
    }
    
    @IBOutlet weak var requestButton: UIButton! {
        didSet {
            setRequestButton()
        }
    }
    @IBOutlet weak var hartButton: UIButton! {
        didSet {
//            // APIとヒットしてから enabledをtrueに
//            hartButton.isEnabled = false
            hartButton.setTitle("", for: .normal)
            setHartButton()
        }
    }
    @IBOutlet weak var openCloseStackView: UIStackView!
    @IBOutlet weak var restaurantName: UILabel! {
        didSet {
            restaurantName.text = "情報なし"
            restaurantName.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    @IBOutlet weak var openTime: UILabel! {
        didSet {
            openTime.text = "情報なし"
            openTime.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    @IBOutlet weak var closeTime: UILabel! {
        didSet {
            closeTime.text = "情報なし"
            closeTime.font = .systemFont(ofSize: 14, weight: .medium)
        }
    }
    @IBOutlet weak var vacancyState: UILabel! {
        didSet {
            vacancyState.text = "情報なし"
            vacancyState.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    
    public var delegate: cardViewDelegate?
    
    public var hartButtonState: isSelected = .normal
    public var requestButtonState: isRequested = .normal
    
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
        requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
    
    // modelを全部持ってくるのではなく、検索と一致するmodelのみを持ってくるように変換
    // つまり、このconfigureは、modelがあるときだけ、呼び出される予定
    public func configure(with model: PlaceModel, request requestState: Bool) {
        // model の情報がなかったらそもそも、このメソッドに入らない設定にした
        // これは、Google Place APIと連動すればいいかも
        let vacantSeatsArray = model.seats
        // 空きありがdefaultの状態
        var noVacancy = false
        restaurantName.text = model.name ?? ""
        openTime.text = "Open: 10:00AM"
        closeTime.text = "Close: 20:00PM"
        
        if requestState {
            // requestされたのであれば、
            for i in 0..<(vacantSeatsArray.count) {
                if let hasVacant = vacantSeatsArray[i].isUsed {
                    vacancyState.text = "満席"
                    vacancyState.textColor = .red.withAlphaComponent(0.7)
                    noVacancy = hasVacant
                    break
                }
            }
            
            if !noVacancy {
                vacancyState.text = "空席あり"
                vacancyState.textColor = UIColor(rgb: 0x06B32A)
            }
        } else {
            // requestされてないところであれば
            vacancyState.text = "カメラを設置していません"
            vacancyState.textColor = .black
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

// UIColorをhexタイプで設定できるように
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

//if model.isEmpty {
//    // 見つかりませんでした！というalertを表示させたい！
//
//    restaurantName.text = "検索結果なし"
//    openTime.text = "検索結果なし"
//    closeTime.text = "検索結果なし"
//    vacancyState.text = "検索結果なし"
//    vacancyState.textColor = .lightGray
//    vacancyState.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//    requestButton.setTitle("検索結果なし", for: .normal)
//    requestButton.backgroundColor = .lightGray
