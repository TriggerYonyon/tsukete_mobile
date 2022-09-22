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

enum CheckType {
    case isChecked
    case notChecked
}

class DetailCardVC: UIViewController {
    let scrollView: UIScrollView! = UIScrollView()
    var restaurantTitle = ""
    var displayType = DisplayType.seats
    var checkType = CheckType.notChecked
    let liveSeatsView = LiveSeatsView(frame: .zero)
    let seatTableView: UITableView! = UITableView()
    
    // mainVCからのcheck Stateをそのまま、受け取る
    // お店の名前: [お気に入りリストに入れたか、 リクエストしたか]のDictionary
    var checkStatePlaceDict = [String: [Bool]]()
    
    var image1 = UIImage()
    var image2 = UIImage()
    var image3 = UIImage()
    
    // requestボタンの状態
    var requestState: isRequested = .normal
    
    // seats Model
    var seatsModelByPlace: [PlaceModel] = [PlaceModel]()
    // seats Model Index
    var searchModelIndex = 0
    
    @IBOutlet weak var restaurantLabel: UILabel! {
        didSet {
            restaurantLabel.text = restaurantTitle
            restaurantLabel.font = .systemFont(ofSize: 20, weight: .bold)
        }
    }
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            dismissButton.setTitle("", for: .normal)
            dismissButton.tintColor = .systemGray
        }
    }
    
    @IBOutlet weak var seatsTypeSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var seatCheckButton: UIButton! {
        didSet {
            seatCheckButton.setTitle("", for: .normal)
            seatCheckButton.tintColor = .lightGray
        }
    }
    @IBOutlet weak var seatCheckInfoView: UIView!
    
    @IBOutlet weak var vacantSeatImage: UIView! {
        didSet {
            vacantSeatImage.backgroundColor = UIColor(rgb: 0x06B3EA)
            vacantSeatImage.layer.cornerRadius = vacantSeatImage.bounds.height / 2
        }
    }
    @IBOutlet weak var useSeatImage: UIView! {
        didSet {
            useSeatImage.backgroundColor = UIColor(rgb: 0xFE5151)
            useSeatImage.layer.cornerRadius = useSeatImage.bounds.height / 2
        }
    }
    
    
    
    @IBOutlet weak var seatInfoView: UIView! {
        didSet {
            seatInfoView.translatesAutoresizingMaskIntoConstraints = false
            seatInfoView.topAnchor.constraint(equalTo: seatCheckInfoView.bottomAnchor, constant: 5).isActive = true
            seatInfoView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            seatInfoView.backgroundColor = .systemGray5
        }
    }
    
    @IBOutlet weak var checkOnlyVacantSeat: UIButton!
    
    
    // didSetの中で間数を設けて、処理させると、なぜかlayoutでerrorがでちゃう
    // (思う通りにlayout表示されない件)
    @IBOutlet weak var restaurantDetailView: testCustomView! {
        didSet {
            restaurantDetailView.restaurantName.text = restaurantTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
        setScrollView()
        self.view.sendSubviewToBack(scrollView)
        
        setImage()
        
        setCardConstraints()
        setSegmentConstraints()
        self.view.addSubview(liveSeatsView)
        setLiveSeatsView()
        setViewDataConfigure()
        
        self.view.addSubview(seatTableView)
        self.restaurantDetailView.delegate = self
        fetchRequestState()
        
        seatTableView.isScrollEnabled = false
        setTableViewConstraints()
        seatTableView.delegate = self
        seatTableView.dataSource = self
        registerCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        seatTypeViewInitDisplay()
    }
    
    // ⚠️まだ! 空席のみのlistを表示
    @IBAction func checkVacantSeatClicked(_ sender: Any) {
        if checkType == .notChecked {
            checkOnlyVacantSeat.tintColor = .systemBlue.withAlphaComponent(1.0)
            checkType = .isChecked
        } else {
            checkOnlyVacantSeat.tintColor = .lightGray
            checkType = .notChecked
        }
    }
    
    func setImage() {
        restaurantDetailView.image1.image = image1
        restaurantDetailView.image2.image = image2
        restaurantDetailView.image3.image = image3
    }
    
    // detail Viewをconfigure
    func setViewDataConfigure() {
        var requestState = false
        
        if checkStatePlaceDict[restaurantTitle] != nil {
            // nilがないなら、(すでに検索をしてみたお店のcase)
            requestState = checkStatePlaceDict[restaurantTitle]![0]
        }
        
        restaurantDetailView.configure(with: seatsModelByPlace[searchModelIndex], request: requestState)
        checkStateConfigure(with: checkStatePlaceDict)
    }
    
    
    private func registerCell() {
        seatTableView.register(UINib(nibName: "SeatTableViewCell", bundle: nil), forCellReuseIdentifier: "SeatTableViewCell")
    }
    
    private func seatTypeViewInitDisplay() {
        if displayType == .seats {
            seatTableView.alpha = 0.0
            liveSeatsView.alpha = 1.0
        }
    }
    
    private func setScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
    }
    
    private func setTableViewConstraints() {
        seatTableView.translatesAutoresizingMaskIntoConstraints = false
        seatTableView.topAnchor.constraint(equalTo: seatInfoView.bottomAnchor).isActive = true
        seatTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 35).isActive = true
        seatTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        seatTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setSegmentConstraints() {
        seatsTypeSegmentControl.translatesAutoresizingMaskIntoConstraints = false
        seatsTypeSegmentControl.topAnchor.constraint(equalTo: restaurantDetailView.bottomAnchor, constant: 20).isActive = true
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
        
        liveSeatsView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        liveSeatsView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        liveSeatsView.topAnchor.constraint(equalTo: seatInfoView.bottomAnchor).isActive = true
        liveSeatsView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    private func setCardConstraints() {
        restaurantDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        restaurantDetailView.topAnchor.constraint(equalTo: restaurantLabel.bottomAnchor, constant: 30).isActive = true
        // すでに、layoutが設定されているのであれば、heightConstraintsを再び設定する必要はない
//        restaurantDetailView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        // requestボタンをクリックした後のみ、viewを見れるので、request Buttonを無くす必要があると考えた
//        restaurantDetailView.requestButton.isHidden = true
//        restaurantDetailView.requestButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        
        restaurantDetailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        restaurantDetailView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 35).isActive = true
        restaurantDetailView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -35).isActive = true
        
        restaurantDetailView.layer.cornerRadius = 15
        restaurantDetailView.clipsToBounds = true
        restaurantDetailView.layer.borderColor = UIColor.lightGray.cgColor
        restaurantDetailView.layer.borderWidth = 1
    }
    
    // Data Model 関連
    // mainVCから、受け取ったmodelのcheckStateを反映する
    func checkStateConfigure(with stateDict: [String: [Bool]]) {
        // model があるときだけ、detail Viewに入る
        guard let hasRestauName = restaurantDetailView.restaurantName.text else {
            return
        }
        
        if stateDict[hasRestauName] != nil {
            let requestState = stateDict[hasRestauName]![0]
            let likeState = stateDict[hasRestauName]![1]
            
            // hartButtonのclick状態に合わせて、buttonのstate初期値を設定
            switch likeState {
            case true:
                restaurantDetailView.hartButtonState = .selected
                restaurantDetailView.setHartButton()
            case false:
                restaurantDetailView.hartButtonState = .normal
                restaurantDetailView.setHartButton()
            }
            
            switch requestState {
            case true:
                print(requestState)
            case false:
                print(requestState)
            }
        }
    }
    
    // requestの状態に合わせて、cardViewのconfigureを行う
    func fetchRequestState() {
        if requestState == .normal {
            isNotRequestApplied()
        } else {
            isRequestApplied()
        }
    }
    
    func isRequestApplied() {
        restaurantDetailView.requestButton.setTitle("リクエスト申請中", for: .normal)
        restaurantDetailView.requestButton.setTitleColor(.white, for: .normal)
        // backGroundの反映はうまくできた
        restaurantDetailView.requestButton.backgroundColor = UIColor(rgb: 0xA9A9A9)
//        cardView.requestButton.isEnabled = false
        
        restaurantDetailView.vacancyState.text = "リクエスト承諾をお待ちください"
        restaurantDetailView.vacancyState.textColor = UIColor(rgb: 0x0000CD)
    }
    
    func isNotRequestApplied() {
        restaurantDetailView.requestButton.setTitle("¥ 設置リクエスト", for: .normal)
        restaurantDetailView.requestButton.setTitleColor(.black, for: .normal)
        restaurantDetailView.requestButton.backgroundColor = UIColor(rgb: 0xFFBC42)
        
        restaurantDetailView.vacancyState.text = "カメラを設置していません"
        restaurantDetailView.vacancyState.textColor = .black
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension DetailCardVC: cardViewDelegate {
    func noHaveSearchResultEvent() {
        print("no have result data")
    }
    
    func requestButtonEvent() {
        print("DetaialCardPage -> RequestPage")
        print("button tapped!")
    }
    
    func hartButtonEvent() {
        print("click")
        
        if restaurantDetailView.hartButtonState == .normal {
            restaurantDetailView.hartButtonState = .selected
            restaurantDetailView.setHartButton()
            restaurantDetailView.hartButton.layer.add(restaurantDetailView.bounceAnimation, forKey: nil)
            print("normal -> selected")
        } else {
            restaurantDetailView.hartButtonState = .normal
            restaurantDetailView.setHartButton()
            restaurantDetailView.hartButton.layer.add(restaurantDetailView.bounceAnimation, forKey: nil)
            print("selected -> normal")
        }
    }
    
    
}

extension DetailCardVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // その場所のseatsの数だけを表示
        return self.seatsModelByPlace[0].seats.count
    }
    
    // RowCellを特定
    // ❗️cellは、これでOk
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeatTableViewCell", for: indexPath) as! SeatTableViewCell
        
        // ⚠️modelに合わせて変更するつもり
        // people capacity
        let placeInfo = self.seatsModelByPlace[0]
        let seatModel = self.seatsModelByPlace[0].seats[indexPath.row]
        let seatCapacity = seatModel.capacity?.description ?? "0"
        
        cell.peopleLabel.text = seatCapacity + "人"
        
        if seatModel.type == "テーブル" {
            cell.seatType.image = UIImage(named: "table")
        } else {
            cell.seatType.image = UIImage(named:"chair")
        }
        
        if let hasConcent = seatModel.hasOutlet {
            if hasConcent {
                cell.concentImage.image = UIImage(named: "concent")
            }
        }
        
        if let hasTabacoSeat = placeInfo.nonSmoking {
            if hasTabacoSeat {
                cell.tabacoImage.image = UIImage(named: "noTabaco")
            }
        }
        
        if let hasUsedAlready = seatModel.isUsed {
            if hasUsedAlready {
                cell.vacancyImage.backgroundColor = UIColor(rgb: 0xFE5151)
            } else {
                cell.vacancyImage.backgroundColor = UIColor(rgb: 0x06B3EA)
            }
        }
        
        return cell
    }
    
    // Select Cellに関するfunc
    // ❗️ここは、これでok
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailSeatsVC = UIStoryboard(name: "DetailListSeatsVC", bundle: nil).instantiateViewController(withIdentifier: "DetailListSeatsVC") as! DetailListSeatsVC
        tableView.deselectRow(at: indexPath, animated: true)
        detailSeatsVC.seatsInfo = self.seatsModelByPlace[0].seats[indexPath.row]
        detailSeatsVC.modalPresentationStyle = .fullScreen
        self.present(detailSeatsVC, animated: true, completion: nil)
    }
    
    
    
    
    
}
