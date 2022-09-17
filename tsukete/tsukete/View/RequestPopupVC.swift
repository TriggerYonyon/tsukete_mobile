//
//  RequestPopupVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/16.
//

import UIKit

class RequestPopupVC: UIViewController {
    
    @IBOutlet weak var popupView: UIView! {
        didSet {
            popupView.layer.cornerRadius = 15
            popupView.layer.shadowColor = UIColor.black.cgColor
            popupView.layer.masksToBounds = false
            popupView.layer.shadowOpacity = 0.7
        }
    }
    
    @IBOutlet weak var requestImageView: UIImageView! {
        didSet {
            requestImageView.image = UIImage(named: "thankYouImage")
            requestImageView.contentMode = .scaleAspectFit
        }
    }
    @IBOutlet weak var thankYouLabel: UILabel! {
        didSet {
            thankYouLabel.text = "リクエストありがとうございます"
            thankYouLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        }
    }
    
    // viewをpresentしたらstateは、常にtrueである
    var presentViewState = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 余白の画面をクリックしたらviewをdismissするように
    // Try 方法1. override touchsBeganメソッドで画面をdimiss
    // Result: popup viewをクリックしても、dismiss viewになった
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true) {
            self.presentViewState = false
            print("画面のtapによるdismiss")
        }
    }
    
    
//    // Try 方法2. viewにgestrue登録
//    // Result: Popup viewをクリックしても、同じくdismiss viewされた
//    private func dismissTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewByTap))
//        self.popupView.removeGestureRecognizer(tapGesture)
//        self.view.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func dismissViewByTap() {
//        self.dismiss(animated: true)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
