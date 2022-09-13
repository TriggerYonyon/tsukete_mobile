//
//  ViewController.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit

// アプリのlogic:
// 最初は、Onboarding View(アプリの説明)を表示させる
// アプリの説明の確認の後、main page(google map)があるとこに画面遷移

class ViewController: UIViewController {
    
    // 説明のviewを表示したかのbool 編数
    //⚠️永久的にこの値を保存したいなら、localにuserDefaultsを用いて記憶させるものがある
    var didShowOnboardingView = false
    
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapButton.addTarget(self, action: #selector(googleMapPresent), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if didShowOnboardingView == false {
            didShowOnboardingView = true
            
            let pageVC = OnboardingPageVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: .none)
            
            pageVC.modalPresentationStyle = .fullScreen
            self.present(pageVC, animated: true, completion: nil)
            
        }
    }
    
    @objc func googleMapPresent() {
        let googleMapVC = MapViewController(nibName: "MapViewController", bundle: nil)
        self.present(googleMapVC, animated: true, completion: nil)
    }
    


}

