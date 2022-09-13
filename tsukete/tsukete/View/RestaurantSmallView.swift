//
//  RestaurantSmallView.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/13.
//

import UIKit

protocol RestaurantSmallViewDelegate {
    func requestButtonEvent()
}

// Stotyboard上で描かれるように設定した (すぐ確認できるように)
@IBDesignable
class RestaurantSmallView: UIView {
    public var delegate: RestaurantSmallViewDelegate?
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
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: "RestaurantSmallView", bundle: bundle)
//        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
//
//
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.layer.cornerRadius = view.bounds.height / 2
//        view.clipsToBounds = true
//        view.backgroundColor = .systemBlue
//        self.addSubview(view)
        let identifier = String(describing: type(of: self))
        let nibs = Bundle.main.loadNibNamed(identifier, owner: self, options: nil)

        guard let customView = nibs?.first as? UIView else {
            fatalError("Error when load custom View")
        }
        
        customView.frame = self.bounds
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        customView.layer.cornerRadius = 15
        customView.backgroundColor = .green
        customView.layer.borderColor = UIColor.lightGray.cgColor
        customView.layer.borderWidth = 3
        customView.layer.cornerRadius = 15
        customView.clipsToBounds = true
        self.addSubview(customView)
//
    }
    
    @IBAction func requestButtonClicked(_ sender: Any) {
        self.delegate?.requestButtonEvent()
    }
    
    
}
