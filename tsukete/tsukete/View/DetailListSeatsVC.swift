//
//  DetailListSeatsVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import UIKit

class DetailListSeatsVC: UIViewController {
    
    var seatsInfo: SeatsInfo?
    private let scrollView: UIScrollView = {
       let view = UIScrollView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let contentView: UIView = {
       let view = UIView()
        view.backgroundColor = .green
        return view
    }()
    
    @IBOutlet weak var restaurantLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(scrollView)
        setScrollViewConstraints()
        self.view.sendSubviewToBack(scrollView)
    }
    
    private func setScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
