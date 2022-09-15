//
//  ViewController.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit
import GoogleMaps
import CoreLocation

// アプリのlogic:
// 最初は、Onboarding View(アプリの説明)を表示させる
// アプリの説明の確認の後、main page(google map)があるとこに画面遷移

//protocol MainViewDelegate {
//    func isAlreadyClicked(selected: isSelected)
//}

class ViewController: UIViewController {
//
//    var delegate: MainViewDelegate?
    // 説明のviewを表示したかのbool 編数
    //⚠️永久的にこの値を保存したいなら、localにuserDefaultsを用いて記憶させるものがある
    var didShowOnboardingView = false
    var showLocationRequest = false
    var appearKeyboard = false
    // お店の名前を検索でヒット
    var searchText = ""
    // APIから戻ってきたnameとsearchTextをヒットさせ、その中の住所を持ってくる
    var targetAddress = ""
    // お店の名前をAPIから事前に登録
    var restauName = ""
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 0))
    let geocoder = CLGeocoder()
    
    // Server API Model
    // リクエストしたお店かどうか
    var requestState = false
    // イメージがあるかどうか
    var imageData = [UIImage]()
    var resultPlaceModel: [PlaceModel] = [PlaceModel]()
    var networkLayer = NetworkLayer()
    
    @IBOutlet weak var cardView: testCustomView! {
        didSet {
            cardView.isHidden = true
        }
    }
    
    private var mapView: GMSMapView!
    
//    private var clusterManager: GMUClusterManager!
    // ⚠️現在地を東京にcustom 設定
    //35.681223
    //139.767059
    var defaultPositionLat: CLLocationDegrees = 35.681223
    var defaultPositionLng: CLLocationDegrees = 139.767059
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigateConfigure()
        searchBarConfigure()
        mapConfigure()
        markerConfigure()
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
        
        setCardView()
        setCardConstraints()
        self.cardView.delegate = self
        dismissKeyboardByTap()
        // ⚠️API modelからconfigureするつもり
//        cardView.configure(state: requestState)
        cardViewGesture()
        addKeyboardObserver()
        requestRestaurantAPI()
        requestGetImage()
    }
    
    // Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: 🔥検索した名前の位置を読み込む
    func getLocation() {
        
    }
    
    // Image写真の処理
    // ⚠️今回は、imageは使わないことにした
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void ) {
        networkLayer.request(type: .justURL(urlString: urlString)) { data, response, error in
            if let hasData = data {
                completion(UIImage(data: hasData))
                return
            }
            completion(nil)
        }
    }
    
    func requestRestaurantAPI() {
        //Query Stringを使って、target要素を指定
        // 今回は Queryなしで
        // shopsだけで必要な情報は読み込める
        let url = "http://localhost:8080/api/shops"
        
        networkLayer.request(type: .justURL(urlString: url)) { data, response, error in
            if let hasData = data {
                
                do {
                    self.resultPlaceModel = try JSONDecoder().decode([PlaceModel].self, from: hasData)
                    
                    // requestAPIから事前に登録
                    self.restauName = self.resultPlaceModel.first?.name ?? ""
                    print(self.restauName)
                    self.getAddressString()
                    
                    DispatchQueue.main.async {
                        // CardViewの情報をModelの情報に変更
                        self.cardView.configure(with: self.resultPlaceModel)
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func requestGetImage() {
        let imageUrl1 = "http://drive.google.com/uc?export=view&id=1EV5zj7Rz5HG8uUWCvEb8lxehlDPfrACM"
        let imageUrl2 = "http://drive.google.com/uc?export=view&id=1OXit8NrEDtTKea7rxkFN286J7bX20X0K"
        let imageUrl3 = "http://drive.google.com/uc?export=view&id=1q8ORuIudXwedg-DJ8wfHp3fp3yVLUgcF"
        
        // ⚠️配列でやろうとしたが、できなかった
        self.loadImage(urlString: imageUrl1) { image in
            DispatchQueue.main.async {
                self.cardView.image1.image = image
            }
        }
        
        self.loadImage(urlString: imageUrl2) { image in
            DispatchQueue.main.async {
                self.cardView.image2.image = image
            }
        }
        
        self.loadImage(urlString: imageUrl3) { image in
            DispatchQueue.main.async {
                self.cardView.image3.image = image
            }
        }
    }
    
    func getAddressString() {
        if let hasData = resultPlaceModel.first {
            targetAddress += hasData.prefecture ?? ""
            targetAddress += hasData.locality ?? ""
            targetAddress += hasData.street ?? ""
            targetAddress += hasData.building ?? ""
            print(targetAddress)
        } else {
            return
        }
    }
    
    // ⚠️search button押したら、nameがmatchするかを確認
    // そのあと、targetAddressでgeocodingして、mapにmarker 表示
    func isMatchedName() -> Bool {
        if searchText == restauName {
            return true
        } else {
            return false
        }
    }
    
    // table Viewは、resultPlaceModel[indexPath.row]みたいにやる
    
    private func navigateConfigure() {
        // No title of Navigation Title
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    private func mapConfigure() {
        let camera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: defaultPositionLat, longitude: defaultPositionLng, zoom: 11)
        mapView = GMSMapView(frame: self.view.bounds, camera: camera)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    private func searchBarConfigure() {
        // NavigationItem に UISearchBar入れて作る
        
        searchBar.placeholder = "店舗検索"
        // 左のSearch Image
        searchBar.setImage(UIImage(named: "icSearchNonW"), for: UISearchBar.Icon.search, state: .normal)
        // 右の x ボタンのImage
        searchBar.setImage(UIImage(named: "icCancel"), for: .clear, state: .normal)
        
        let searchBarButtonItem = UIBarButtonItem(customView: searchBar)
        let profileButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(moveToProfilePage))
        self.navigationItem.rightBarButtonItems = [profileButtonItem, searchBarButtonItem]
        
        searchBar.delegate = self
        // cancel Buttonを表す
        searchBar.showsCancelButton = false
//        searchBar.showsSearchResultsButton = true
    }
    
    @objc func moveToProfilePage(_ sender: UIBarButtonItem) {
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        
        if appearKeyboard {
            searchBar.endEditing(true)
            appearKeyboard = false
        }
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        print("mainPage -> profilePage")
    }
    
    private func cardViewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(detailCardViewMove))
        cardView.addGestureRecognizer(tapGesture)
    }
    
    @objc func detailCardViewMove() {
        guard let detailVC = UIStoryboard(name: "DetailCardVC", bundle: nil).instantiateViewController(withIdentifier: "DetailCardVC") as? DetailCardVC else {
            return
        }
        
        // dataをdetailVCに渡す
        detailVC.seatsModelByPlace = resultPlaceModel
        detailVC.restaurantTitle = cardView.restaurantName.text!
        // CoverVerticalのモード
        detailVC.modalTransitionStyle = .coverVertical
        self.present(detailVC, animated: true, completion: nil)
    }
    
    private func setCardView() {
        cardView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
    }
    
    private func setCardConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false

        cardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
        cardView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cardView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        cardView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        guard appearKeyboard == false else {
            return
        }
        appearKeyboard = true
        print(appearKeyboard)
        
        if !self.cardView.isHidden {
            self.cardView.isHidden = true
        }
        
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        guard appearKeyboard == true else {
            return
        }
        
        appearKeyboard = false
        
        print(appearKeyboard)
    }
    
    private func markerConfigure() {
        let position = CLLocationCoordinate2D(latitude: defaultPositionLat, longitude: defaultPositionLng)
        let marker = GMSMarker(position: position)
        marker.title = "Tokyo"
        // markerの色変更
        marker.icon = GMSMarker.markerImage(with: .orange.withAlphaComponent(0.5))
        marker.map = mapView
        marker.appearAnimation = .pop
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didShowOnboardingView == false {
            didShowOnboardingView = true
            
            let pageVC = OnboardingPageVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: .none)

            pageVC.modalPresentationStyle = .overCurrentContext
            self.present(pageVC, animated: true, completion: nil)
        }
    }
    
    private func dismissKeyboardByTap() {
        // どこでもtapしたらkeyboardが表示されないように
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.view.endEditing))
        mapView.addGestureRecognizer(tapGesture)
    }
}

extension ViewController: GMSMapViewDelegate {
    // Map ViewをTapすることによるEvent
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // Keyboardを下ろす
        if appearKeyboard {
            print("keyboard is appearing")
            // searchBar の入力によるkeyboardが現れたら、下ろす
            searchBar.endEditing(true)
            appearKeyboard = false
        }
        
        
        if cardView.isHidden == false {
            print("true")
            mapView.settings.myLocationButton = true
            cardView.isHidden = true
        } else {
            print("false")
            return
        }
    }
    
    // MarkerをTapしたら呼び出されるメソッド
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("You tapped at \(marker.position.latitude), \(marker.position.longitude)")
        cardView.isHidden = false
        mapView.settings.myLocationButton = false
        return true
    }
}

// MARK: SearchBar 関連
// ⚠️Google Place API 場所検索でお店をヒットするつもり
extension ViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let hasText = searchBar.text else {
            return
        }
        print("search")
        
        searchText = hasText
        if isMatchedName() {
            print("true: \(restauName)")
            // MARK: 🔥 searchして、ヒットしたらGeoCodingを行う
            
        }
        
        print(searchText)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let hasText = searchController.searchBar.text else {
            return
        }
        print(hasText)
    }
    

    
    // search bar touch後、入力を始めたときに呼び出されるメソッド
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !searchBar.showsCancelButton {
            searchBar.showsCancelButton = true
        }
        
        print("search Start!")
    }
    
    // cancel button click時に呼び出されるメソッド
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.showsCancelButton {
            searchBar.showsCancelButton = false
        }
        
        searchBar.endEditing(true)
    }
    
    // 検索入力値が編集されるたびに呼び出されるメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let hasText = searchBar.text else {
            return
        }
        
        print(hasText)
        print(searchText)
    }
    
}

extension ViewController: cardViewDelegate {
    func requestButtonEvent() {
        print("mainPage -> RequestPage")
        print("button tapped!")
    }
    
    func hartButtonEvent() {
        if cardView.hartButtonState == .normal {
            cardView.hartButtonState = .selected
            cardView.setHartButton()
            cardView.hartButton.layer.add(cardView.bounceAnimation, forKey: nil)
            print("normal -> selected")
        } else {
            cardView.hartButtonState = .normal
            cardView.setHartButton()
            cardView.hartButton.layer.add(cardView.bounceAnimation, forKey: nil)
            print("selected -> normal")
        }
        
        // DetailCardVCにも渡すためのlogicを追加
    }
}








//        clusterConfig()
//        clusterManager.setDelegate(self, mapDelegate: self)
    
    // ⚠️modelによって、帰るつもり
//    func configure() {
//        // serverAPIのresultに合わせて config
//        if !imageData.isEmpty {
//            // Imageを3つに絞る
//            // ⚠️途中の段階:Image URL処理をまだ
//            cardView.image1.image = imageData[0]
//            cardView.image2.image = imageData[1]
//            cardView.image3.image = imageData[2]
//        } else {
//            cardView.image1.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//            cardView.image2.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//            cardView.image3.image = UIImage(systemName: "photo")?.withTintColor(.lightGray)
//        }
//
//        if requestState == false {
//            cardView.restaurantName.text = "Sansan食堂"
//            cardView.openTime.text = "Open: 10:00AM"
//            cardView.closeTime.text = "Close: 20:00PM"
//            cardView.vacancyState.text = "カメラを設置していません"
//            cardView.vacancyState.textColor = .lightGray
//            cardView.vacancyState.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        } else {
//            cardView.restaurantName.text = "Sansan食堂"
//            cardView.openTime.text = "Open: 10:00AM"
//            cardView.closeTime.text = "Close: 20:00PM"
//            cardView.vacancyState.text = "空きあり"
//            cardView.vacancyState.textColor = UIColor(rgb: 0x06B3EA)
//            cardView.vacancyState.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//            cardView.requestButton.isHidden = true
//        }
//    }



//    func setSearchBar2(){
//         //서치바 만들기
//         let searchBar = UISearchBar()
//         searchBar.placeholder = "Search"
//         //왼쪽 서치아이콘 이미지 세팅하기
//         searchBar.setImage(UIImage(named: "icSearchNonW"), for: UISearchBar.Icon.search, state: .normal)
//         //오른쪽 x버튼 이미지 세팅하기
//         searchBar.setImage(UIImage(named: "icCancel"), for: .clear, state: .normal)
//         //네비게이션에 서치바 넣기
//        self.navigationItem.titleView = searchBar
//
//         if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
//             //서치바 백그라운드 컬러
//             textfield.backgroundColor = UIColor.black
//             //플레이스홀더 글씨 색 정하기
//             textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
//             //서치바 텍스트입력시 색 정하기
//             textfield.textColor = UIColor.white
//             //왼쪽 아이콘 이미지넣기
//             if let leftView = textfield.leftView as? UIImageView {
//                 leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
//                 //이미지 틴트컬러 정하기
//                 leftView.tintColor = UIColor.white
//             }
//             //오른쪽 x버튼 이미지넣기
//             if let rightView = textfield.rightView as? UIImageView {
//                 rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
//                 //이미지 틴트 정하기
//                 rightView.tintColor = UIColor.white
//             }
//
//         }
//     }

// Clusterの方 _ 実装途中


// Clusterに関するやつ

//        if let poiItem = marker.userData as? POIItem {
//            NSLog("Did tap marker for cluster item \(poiItem)")
//        } else {
//            NSLog("Did tap a normal marker")
//        }
//        return false

//
//extension ViewController: GMUClusterManagerDelegate {
//    // MARK: - GMUClusterManagerDelegate
//    private func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) {
//        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position, zoom: mapView.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//        mapView.moveCamera(update)
//    }
//
//}
//    func clusterConfig() {
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
//
//        // マーカーをランダムに生成して Map 上に表示
//        generateClusterItems()
//    }
//
//    private func generateClusterItems() {
//        let extent = 0.01
//        for _ in 1...100 {
//            let lat = defaultPositionLat + extent * randomScale()
//            let lng = defaultPositionLng + extent * randomScale()
//            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng))
//            clusterManager.add(item)
//        }
//           // Map にマーカーを描画
//           clusterManager.cluster()
//    }
//
//    private func randomScale() -> Double {
//        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
//    }


