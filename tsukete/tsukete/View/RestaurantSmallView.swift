//
//  RestaurantSmallView.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/13.
//

import UIKit

// Stotyboard上で描かれるように設定した (すぐ確認できるように)
//@IBDesignable
class RestaurantSmallView: UIView {
    @IBOutlet var customView: UIView!
    
    var hasRequested = false
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var vacancyState: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var closeTimeLabel: UILabel!
    @IBOutlet weak var requestButton: UIButton! {
        didSet {
            setRequestbutton(requested: hasRequested)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadXib()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadXib()
    }
    
    func setRequestbutton(requested: Bool) {
        if !requested {
            requestButton.layer.cornerRadius = 15
            requestButton.backgroundColor = .yellow
            requestButton.setTitle("¥ 設置リクエスト", for: .normal)
            requestButton.setTitleColor(.secondaryLabel, for: .normal)
        } else {
            requestButton.isHidden = true
        }
    }
    
    private func loadXib() {
        let identifier = String(describing: type(of: self))
        Bundle.main.loadNibNamed(identifier, owner: self, options: nil)
        
        customView.frame = self.bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        customView.backgroundColor = .white
        
//        customView.layer.cornerRadius = 15
//        customView.backgroundColor = .green
//        customView.layer.borderColor = UIColor.lightGray.cgColor
//        customView.layer.borderWidth = 3
//        customView.layer.cornerRadius = 15
//        customView.clipsToBounds = true
        self.layer.cornerRadius = 15
        self.backgroundColor = .green
        self.addSubview(customView)
    }

}
