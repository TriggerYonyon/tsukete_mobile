//
//  LiveSeatsView.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import UIKit

protocol LiveSeatsViewDelegate {
    func seatButtonTapped()
}

class LiveSeatsView: UIView {
    public var delegate: LiveSeatsViewDelegate?
    private let xibName = "LiveSeatsView"
    
    @IBOutlet var customView: UIView!
    @IBOutlet weak var liveSeatsImageView: UIImageView! {
        didSet {
            setImage()
        }
    }
    
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
        customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(customView)
    }
    
    // ⚠️今回は時間上、座席のリアルタイムな情報は、例のimageにしました。
    private func setImage() {
        liveSeatsImageView.image = UIImage(named: "seatsExample")
        liveSeatsImageView.contentMode = .scaleAspectFill
    }
    
    
}
