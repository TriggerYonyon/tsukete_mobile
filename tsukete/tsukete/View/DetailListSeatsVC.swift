//
//  DetailListSeatsVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import UIKit

// scroll viewを追加した
class DetailListSeatsVC: UIViewController {
    
    var seatsInfo: SeatsInfo?
    private let verticalScrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .white
        return view
    }()
    
//    private let contentView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .green
//        return view
//    }()
    
    private let seatDetailView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    @IBOutlet weak var restaurantLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        addSubView()
//
////        setContentViewConstraints()
//        setverticalScrollViewConstraints()
//        setSeatDetailViewConstraints()
//        verticalScrollView.showsVerticalScrollIndicator = true
    }
    
    func addSubView() {
        self.view.addSubview(verticalScrollView)
        verticalScrollView.addSubview(seatDetailView)
//        contentView.addSubview(seatDetailView)
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setverticalScrollViewConstraints() {
        verticalScrollView.translatesAutoresizingMaskIntoConstraints = false
        verticalScrollView.topAnchor.constraint(equalTo: restaurantLabel.bottomAnchor, constant: 5).isActive = true
        verticalScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        verticalScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        verticalScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
//    private func setContentViewConstraints() {
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.widthAnchor.constraint(equalTo:verticalScrollView.widthAnchor).isActive = true
//        contentView.topAnchor.constraint(equalTo: verticalScrollView.topAnchor).isActive = true
////        contentView.leadingAnchor.constraint(equalTo: verticalScrollView.leadingAnchor).isActive = true
////        contentView.trailingAnchor.constraint(equalTo: verticalScrollView.trailingAnchor).isActive = true
//        contentView.bottomAnchor.constraint(equalTo: verticalScrollView.bottomAnchor).isActive = true
//    }
    
    private func setSeatDetailViewConstraints() {
        seatDetailView.translatesAutoresizingMaskIntoConstraints = false
        seatDetailView.topAnchor.constraint(equalTo: verticalScrollView.topAnchor, constant: 20).isActive = true
        seatDetailView.widthAnchor.constraint(equalTo: verticalScrollView.widthAnchor).isActive = true
//        seatDetailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
//        seatDetailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        // bottomAnchorは、設定ない -> 内容の量に応じて、heightが異なるため
        seatDetailView.heightAnchor.constraint(equalToConstant: 1000).isActive = true
        seatDetailView.bottomAnchor.constraint(equalTo: verticalScrollView.bottomAnchor, constant: 10).isActive = true
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
