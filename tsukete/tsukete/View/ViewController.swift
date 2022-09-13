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

class ViewController: UIViewController {
    
    // 説明のviewを表示したかのbool 編数
    //⚠️永久的にこの値を保存したいなら、localにuserDefaultsを用いて記憶させるものがある
    var didShowOnboardingView = false
    var showLocationRequest = false
    var restaurantView: RestaurantSmallView = RestaurantSmallView(frame: .zero)
    
    private var mapView: GMSMapView!
    
//    private var clusterManager: GMUClusterManager!
    // 現在地を東京にcustom 設定
    let defaultPositionLat = 35.681223
    let defaultPositionLng = 139.767059
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigateConfigure()
        searchBarConfigure()
        mapConfigure()
        markerConfigure()
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
        
        addCardView()
        setCardConstraints()
        self.restaurantView.delegate = self
//        dismissKeyboardByTap()
        
//        clusterConfig()
//        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
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
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 0))
        searchBar.placeholder = "店舗検索"
        // 左のSearch Image
        searchBar.setImage(UIImage(named: "icSearchNonW"), for: UISearchBar.Icon.search, state: .normal)
        // 右の x ボタンのImage
        searchBar.setImage(UIImage(named: "icCancel"), for: .clear, state: .normal)
        let searchBarButtonItem = UIBarButtonItem(customView: searchBar)
        let profileButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle"), style: .plain, target: self, action: #selector(moveToProfilePage))
        self.navigationItem.rightBarButtonItems = [profileButtonItem, searchBarButtonItem]
        
        searchBar.delegate = self
        
    }
    
    @objc func moveToProfilePage(_ sender: UIBarButtonItem) {
        let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        print("mainPage -> profilePage")
    }
    
    private func addCardView() {
        restaurantView.backgroundColor = .brown
        restaurantView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
        restaurantView.layer.cornerRadius = 15
        restaurantView.layer.borderColor = UIColor.lightGray.cgColor
        restaurantView.layer.borderWidth = 3
        self.view.addSubview(restaurantView)
    }
    
    private func setCardConstraints() {
//        guard let restaurantView = Bundle.main.loadNibNamed("RestaurantSmallView", owner: self, options: nil)?.first as? RestaurantSmallView else {
//            return
//        }
//        self.view.insertSubview(restaurantView, aboveSubview: mapView)
        restaurantView.translatesAutoresizingMaskIntoConstraints = false
        
        restaurantView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -500).isActive = true
        restaurantView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        restaurantView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 30).isActive = true
        restaurantView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow() {
        
        
    }
    
    @objc func keyboardWillHide() {
        
    }
    
    private func markerConfigure() {
        let position = CLLocationCoordinate2D(latitude: defaultPositionLat, longitude: defaultPositionLng)
        let marker = GMSMarker(position: position)
        marker.title = "Tokyo"
        // markerの色変更
        marker.icon = GMSMarker.markerImage(with: .systemBlue.withAlphaComponent(1))
        marker.map = mapView
        marker.appearAnimation = .pop
    }
    
    
    
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
       
//    func dismissKeyboardByTap() {
//        // どこでもtapしたらkeyboardが表示されないように
//        let tapGesture = UITapGestureRecognizer(target: mapView, action: #selector(mapView.endEditing))
//        mapView.addGestureRecognizer(tapGesture)
//    }
}

extension ViewController: GMSMapViewDelegate {
    // Tap した latitude と　longitude を表すメソッド
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    // MarkerをTapしたら呼び出されるメソッド
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("You tapped at \(marker.position.latitude), \(marker.position.longitude)")
        return true
    }
        
        // Clusterに関するやつ
        
//        if let poiItem = marker.userData as? POIItem {
//            NSLog("Did tap marker for cluster item \(poiItem)")
//        } else {
//            NSLog("Did tap a normal marker")
//        }
//        return false
}
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

extension ViewController: UISearchBarDelegate {
    
}

extension ViewController: RestaurantSmallViewDelegate {
    func requestButtonEvent() {
        print("mainPage -> RequestPage")
    }
}



//    func setSearchBar2(){
//
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
