//
//  OnboardingPageVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit

class OnboardingPageVC: UIPageViewController {
    var pages = [UIViewController]()
    var bottomButtonMargin: NSLayoutConstraint?
    var pageControl = UIPageControl()
    
    let startIndex = 0
    var currentIndex = 0 {
        didSet {
            pageControl.currentPage = currentIndex
        }
    }
    
    func makePageVC() {
        let itemVC1 = OnboardingItemVC.init(nibName: "OnboardingItemVC", bundle: nil)
        itemVC1.topImage = UIImage(named: "explain1")
        itemVC1.mainText = "混雑状況を知りたい店を選択"
        
        let itemVC2 = OnboardingItemVC.init(nibName: "OnboardingItemVC", bundle: nil)
        itemVC2.topImage = UIImage(named: "explain1")
        itemVC2.mainText = "2nd explain"
        
        let itemVC3 = OnboardingItemVC.init(nibName: "OnboardingItemVC", bundle: nil)
        itemVC3.topImage = UIImage(named: "explain1")
        itemVC3.mainText = "3rd explain"
        
        pages.append(itemVC1)
        pages.append(itemVC2)
        pages.append(itemVC3)
        
        setViewControllers([itemVC1], direction: .forward, animated: true)
        self.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.makePageVC()
        self.makeBottomButton()
        self.makePageControl()
        
    }
    
    func makeBottomButton() {
        let button = UIButton()
        button.setTitle("確認", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        
        button.addTarget(self, action: #selector(dismissPageView), for: .touchUpInside)
        self.view.addSubview(button)
            
        button.translatesAutoresizingMaskIntoConstraints = false
            
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20).isActive = true
        // buttonの高さの設定
        // 基準点を設定せず、ただの数値だけ与えたいなら equalToConstantでいい
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        // bottomAnchorが基準であるため、constantを マイナス数値を入れないとview上に表示されない
        // safeAreaがあるdeviceの場合は、self.view.safeAreaLayoutGuideを基準にするのをおすすめする
        
        //MARK: ボタンのHIDE and Appear機能の実装
        // ✍️ 上記のbottomButtonMarginで記憶させる
        // instanceに記憶させたいときは、isActive設定は書いてはいけない
        bottomButtonMargin = button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        bottomButtonMargin?.isActive = true
        //最初も隠さないといけないから hideButton（）実行
        hideButton()
    }
    
    func makePageControl() {
        self.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        //現在のpageを表すときの、tintcolor
        pageControl.currentPageIndicatorTintColor = .black
        //それ以外のときの基本tintcolor
        pageControl.pageIndicatorTintColor = .lightGray
        //pageの数ほど、　.のUIを表示させる
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = startIndex
        pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -200).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            
        // ✍️PageControlには、その.をクリックして、当てはまるpageに移動するようなEventがある
        // 🌱クリックによるpage移動を不可能とする:
        //isUserInteractionEnabled = false にする
        // 全てのtouchに関するeventは通じないようにするということ
        // pageControl.isUserInteractionEnabled = false
        
        // 🌱クリックによるpage移動を可能とする:
        // addTargetを用いて、event連結する
        // valueChanged: 値が変わることに応じて、eventを起こす
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
    }
        
    @objc func pageControlTapped(sender: UIPageControl) {
        // pageControlのtap（クリック）によるpage移動イベント間数
        // sender.currentPage = tapしたページ
        // currentIndex = 今のページ
        
        if sender.currentPage > currentIndex {
            setViewControllers([pages[sender.currentPage]], direction: .forward, animated: true, completion: nil)
        } else {
            // forward: 左から右に移動するanimation
            setViewControllers([pages[sender.currentPage]], direction: .reverse, animated: true, completion: nil)
        }
        
        currentIndex = sender.currentPage
        buttonPresentation()
    }
    
    @objc func dismissPageView() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension OnboardingPageVC: UIPageViewControllerDataSource {
    //前のページに関連するメソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        self.currentIndex = currentIndex
        // 最初のPageだったら、繋がっている一番最後のPageに移動するようにする
        if currentIndex == 0 {
            return pages.last
        } else {
            return pages[currentIndex - 1]
        }
    }
    
    //後のページに関連するメソッド
    //現在のPageから後のPageに移動するとき、後のPageを返す(移動する)メソッド
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        self.currentIndex = currentIndex
        
        //最後のページである場合
        if currentIndex == pages.count - 1 {
            // Optionalを返すから、Unwrapping 必要なし
            return pages.first
        } else {
            return pages[currentIndex + 1]
        }
    }
}

extension OnboardingPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // first = 最初の画面
        guard let currentVC = pageViewController.viewControllers?.first else {
            return
        }
        
        guard let currentIndex = pages.firstIndex(of: currentVC) else {
            return
        }
        
        self.currentIndex = currentIndex
        buttonPresentation()
    }
    
    func buttonPresentation() {
        if currentIndex == pages.count - 1 {
            // Show Button
            self.showButton()
        } else {
            // Hide Button
            self.hideButton()
        }
        
        //自然なanimation効果を与える (positionの内容の操作ができる)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    func showButton() {
        bottomButtonMargin?.constant = -100
    }
      
    func hideButton() {
        bottomButtonMargin?.constant = 100
    }
}
