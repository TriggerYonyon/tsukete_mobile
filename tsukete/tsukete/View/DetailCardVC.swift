//
//  DetailCardVC.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import UIKit

enum DisplayType {
    case seats
    case lists
}

class DetailCardVC: UIViewController {
    
    var restaurantTitle = ""
    var displayType = DisplayType.seats
    let liveSeatsView = LiveSeatsView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
    
    // seats Model
    var seatsModel: SeatsModel?
    
    @IBOutlet weak var restaurantLabel: UILabel! {
        didSet {
            restaurantLabel.text = restaurantTitle
            restaurantLabel.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    @IBOutlet weak var seatsTypeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var seatsInfoView: UIView!
    
    
    // didSetの中で間数を設けて、処理させると、なぜかlayoutでerrorがでちゃう
    // (思う通りにlayout表示されない件)
    @IBOutlet weak var restaurantDetailView: testCustomView! {
        didSet {
            restaurantDetailView.restaurantName.text = restaurantTitle
            restaurantDetailView.imageStackview.translatesAutoresizingMaskIntoConstraints = false
            restaurantDetailView.imageStackview.heightAnchor.constraint(equalToConstant: 0).isActive = true
            restaurantDetailView.requestButton.translatesAutoresizingMaskIntoConstraints = false
            restaurantDetailView.requestButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
            restaurantDetailView.layer.cornerRadius = 15
            restaurantDetailView.clipsToBounds = true
            restaurantDetailView.layer.borderColor = UIColor.lightGray.cgColor
            restaurantDetailView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var seatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardView()
        setCardConstraints()
        self.view.addSubview(liveSeatsView)
        setLiveSeatsView()
        seatTableView.delegate = self
        seatTableView.dataSource = self
    }
    
    private func registerCell() {
        
    }
    
    @IBAction func segmentSelect(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            displayType = .seats
        case 1:
            displayType = .lists
        default:
            break
        }
        
        // 透明度でviewの入れ替わりを実装してみた
        if displayType == .seats {
            seatTableView.alpha = 0.0
            liveSeatsView.alpha = 1.0
        } else {
            liveSeatsView.alpha = 0.0
            seatTableView.alpha = 1.0
        }
        
    }
    
    private func setLiveSeatsView() {
        liveSeatsView.translatesAutoresizingMaskIntoConstraints = false
        liveSeatsView.topAnchor.constraint(equalTo: seatsInfoView.bottomAnchor).isActive = true
        liveSeatsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    
    
    private func setCardView() {
        restaurantDetailView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
    }
    
    private func setCardConstraints() {
        restaurantDetailView.translatesAutoresizingMaskIntoConstraints = false

        restaurantDetailView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        restaurantDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        restaurantDetailView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        restaurantDetailView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
    }
    
    // Data Model 関連
    private func configure(with: PlaceModel) {
        
        
    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension DetailCardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 1つのSectionに1つのrowを入れる方法で実装
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seatsModel?.results.count ?? 0
    }
    
    // RowCellを特定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeatTableViewCell", for: indexPath) as! SeatTableViewCell
        
        // ⚠️modelに合わせて変更するつもり
        cell.peopleLabel.text = self.seatsModel?.results[indexPath.row].trackName
        
        
        return cell
    }
    
    // Select Cellに関するfunc
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailSeatsVC = UIStoryboard(name: "DetailListSeatsVC", bundle: nil).instantiateViewController(withIdentifier: "DetailListSeatsVC") as! DetailListSeatsVC
        tableView.deselectRow(at: indexPath, animated: true)
        detailSeatsVC.seatsResult = self.seatsModel?.results[indexPath.row]
        self.present(detailSeatsVC, animated: true, completion: nil)
    }
    
    
    
    
    
}
