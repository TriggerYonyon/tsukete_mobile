//
//  ViewController.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/12.
//

import UIKit
import GoogleMaps
import CoreLocation
import CoreData

// アプリのlogic:
// 最初は、Onboarding View(アプリの説明)を表示させる
// アプリの説明の確認の後、main page(google map)があるとこに画面遷移

// Dataの連動のlogic
// 1. お店検索 -> APIに登録されているお店であるかどうかをチェック (requestAPI)
// 2. APIの通り、cardViewに表示される. ここで、imageもapi requestを行い、表示させる ->まだ、coreDataに保存x
// 3. requestボタンやlikeボタンを押したら coreDataのオブジェクトを生成して保存するように
// 3-(1). すでにあるrestaurantかどうかをcheck -> すでにcoredataにある場合　updataCoreData, じゃなければsaveCoreData
// 3-(2). リクエストをしたお店であれば、markerが表示されるように,  likeボタンを押したお店であれば markerはlike buttonのイメージ
// 4. アプリを再起動しても、coreDataが保存されているかを確認


class ViewController: UIViewController {
//
//    var delegate: MainViewDelegate?
    // 説明のviewを表示したかのbool 編数
    //⚠️永久的にこの値を保存したいなら、localにuserDefaultsを用いて記憶させるものがある
    var didShowOnboardingView = false
    var showLocationRequest = false
    var appearKeyboard = false
    
    // 複数のmarkerを生成するための配列
    var markerArray = [GMSMarker]()
    // 複数のcardViewを保存するための配列
    var cardViewsArray = [testCustomView]()
    
    // 最初のtitleは、tokyoにした
    var markerTitle = "Tokyo"
    // お店の名前を検索でヒット
    var searchText = ""
    // APIから戻ってきたnameとsearchTextをヒットさせ、その中の住所を持ってくる
    var targetAddress = ""
    // お店の名前をAPIから事前に登録
    var restauName = ""
    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 300, height: 0))
    let geocoder = CLGeocoder()
    var marker = GMSMarker()
    
    // Server API Model
    // リクエストしたお店かどうか
    // MARK: defaultは false
    var requestState = false
    // イメージがあるかどうか
    var imageData = [UIImage]()
    var resultPlaceModel: [PlaceModel] = [PlaceModel]()
    var networkLayer = NetworkLayer()
    // お店の名前: [お気に入りリストに入れたか、 リクエストしたか]のDictionary
    var checkStatePlaceDict = [String: [Bool]]()
    // modelの配列のindexを初期化
    var modelIndex = 0
    
    // CoreData関連
    // お店のrequest, like list管理
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // CoreDataのentityの配列
    var checkStateLists = [User_checkStateList]()
    var selectedCheckList: User_checkStateList?
    
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
    // 初期値設定 (検索による初期値設定)
    var searchPositionLat: CLLocationDegrees = 35.681223
    var searchPositionLng: CLLocationDegrees = 139.767059
    
    // 最初から指定しちゃう設定
    var defaultPositionLat = 35.662737
    var defaultPositionLng = 139.70899
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigateConfigure()
        searchBarConfigure()
        mapConfigure()
        // MARK: setInitMarker: ❗️CHANGE 指定してからmarkerを設定
        // -> 今後requestしたお店だけ表示されるように変更予定
//        setInitMarker()
//        markerConfigure()
        mapView.delegate = self
        self.view.addSubview(mapView)
        self.view.sendSubviewToBack(mapView)
        
        setCardView()
        setCardConstraints()
        self.cardView.delegate = self
        dismissKeyboardByTap()
        // ⚠️API modelからconfigureするつもり
//        cardView.configure(state: requestState)
        // MARK: APIは最初に読み込む
        requestRestaurantAPI()
        // imageも最初からするようにした
        requestGetImage()
        cardViewGesture()
        addKeyboardObserver()
        fetchCoreData()
    }
    
    // Memory Warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: 🔥検索した名前の位置を読み込む
    func getLocation(placeName place: String, addressName address: String) {
        markerTitle = place
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let hasPlace = placemarks {
                print("placemarks.count: \(hasPlace.count)")
                for place in hasPlace {
                    if let location = place.location {
                        print("latitude: \(location.coordinate.latitude)")
                        print("longitude: \(location.coordinate.longitude)")
                        self.searchPositionLat = location.coordinate.latitude
                        self.searchPositionLng = location.coordinate.longitude
                        print(self.searchPositionLat)
                        print(self.searchPositionLng)
                    }
                }
            }
            //位置修正を行なったため、mapとmarkerを移動させる
            self.mapCameraUpdate()
            self.markerConfigure(newLocate: CLLocationCoordinate2D(latitude: self.searchPositionLat, longitude: self.searchPositionLng))
            
            if self.cardView.isHidden {
                self.cardView.isHidden = false
            }
            
        }
        
        //位置修正を行なったため、mapとmarkerを移動させる
//        mapCameraUpdate()
//        markerConfigure(newLocate: CLLocationCoordinate2D(latitude: self.searchPositionLat, longitude: self.searchPositionLng))
        
    }
    
    // 検索結果がmodelにないときのevent 処理
    func noHaveSearchResultEvent() {
        self.present(setNoResultAlert(), animated: true)
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
    // 最初からserver apiを持ってくるようにすると、問題なしだが、検索するたびにAPIを叩くようにするとエラー生じる
    func requestRestaurantAPI() {
//        let url = "http://localhost:8080/api/shops"
        // deployしたserverの方
        let url = "http://54.199.251.178:8080/api/shops"
        
        networkLayer.request(type: .justURL(urlString: url)) { data, response, error in
            if let hasData = data {
                do {
                    self.resultPlaceModel = try JSONDecoder().decode([PlaceModel].self, from: hasData)
                    // データを受け取った後の同期的な処理を行うところ
                    print("API Request and configure success!")
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // ⚠️cardViewの処理よりも、imageの処理が遅くfetchするため、imageを先にloadしてから cardViewを表示するように修正中
    func requestGetImage() {
        // imageに関しては、ダミーデータを利用
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
                print("load Image3 finish")
            }
        }
    }
    
    // ⚠️search button押したら、nameがmatchするかを確認
    // そのあと、targetAddressでgeocodingして、mapにmarker 表示
    func isMatchedName() -> Bool {
        var isMatched = false
        // APIで読み込んだ全てのデータからsearchTextと一致するお店の名前を探す
        // 一致するお店の名前があるおであれば、そのまま、cardViewとimageをconfigureする
        for i in 0..<resultPlaceModel.count {
            if let hasName = resultPlaceModel[i].name {
                if self.searchText == hasName {
                    // modelIndexをiに設定
                    modelIndex = i
                    isMatched = true
                    break
                }
            }
        }
        
        if !isMatched {
            // matchしたmodelがない場合は、indexを0に初期化
            modelIndex = 0
        }
        
        return isMatched
    }
    
    //textStrには、matchしたお店の名前が入る
    func matchAPIDataWithView(target textStr: String, index i: Int) {
        //TODO: 🔥検索したtextとAPI Data内のnameが一致するときだけ、呼び出されるメソッド
        // requestAPIからRestauNameをmatchする (geoCodingを容易にするため)
        self.restauName = textStr
        print("restaurant Name:", self.restauName)
        // そのお店のアドレスを読み込む
        self.getAddressString(target: i)
        
//        // image 処理とcard処理を同期、非同期処理を組み合わせて行うためのqueue
//        let mainQueue = DispatchQueue(label: "entireFetch")
//        let getImageQueue = DispatchQueue(label: "imageFetch")
        
        DispatchQueue.main.async {
            // MARK: ⚠️途中の段階checkStateの持続的な保存について処理
            // お気に入りリストに入れたか、リクエストしたかは、core Dataに保存しておく
            if self.checkStatePlaceDict[self.restauName] != nil {
                // すでに検索を行い、bool typeが入っていればdetailVCに引き渡す
                // MARK: ⚠️途中の段階
                print(self.checkStatePlaceDict[self.restauName]!)
                self.requestState = self.checkStatePlaceDict[self.restauName]![0]
            } else {
                // 初めて検査した場所であれば、Default: false  falseにしておく
                self.checkStatePlaceDict[self.restauName] = [false, false]
                self.requestState = self.checkStatePlaceDict[self.restauName]![0]
            }
            
            self.cardView.configure(with: self.resultPlaceModel[i], request: self.requestState)
        }
    }
    
    // 探したモデルとmatchしたときだけ呼び出されるメソッド
    func getAddressString(target index: Int) {
        // アドレスは、prefecture, locality, streetまであるかどうかを確認する
        // streetまでのデータがないとgeoCodingするときに、緯度と経度に基づくmarkerが正常に表示されない
        if let hasPrefecture = resultPlaceModel[index].prefecture, let hasLocality = resultPlaceModel[index].locality, let hasStreet = resultPlaceModel[index].street {
            targetAddress += hasPrefecture
            targetAddress += hasLocality
            targetAddress += hasStreet
            // buildingの情報はないかも知れないので、独自な処理を行う
            targetAddress += resultPlaceModel[index].building ?? ""
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
    
    // 最初からマップのカメラ設定
    private func setInitMapConfigure() {
        let camera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: defaultPositionLat, longitude: defaultPositionLng, zoom: 11)
        mapView = GMSMapView(frame: self.view.bounds, camera: camera)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        
//        if !mapView.settings.myLocationButton {
//
//        }
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    // ⚠️検索による位置設定
    private func mapConfigure() {
        let camera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: searchPositionLat, longitude: searchPositionLng, zoom: 11)
        mapView = GMSMapView(frame: self.view.bounds, camera: camera)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
    }
    
    private func mapCameraUpdate() {
//        let newCamera = GMSCameraPosition(latitude: self.searchPositionLat, longitude: self.searchPositionLng, zoom: 13)
        let targetLocate = CLLocationCoordinate2D(latitude: searchPositionLat, longitude: searchPositionLng)
        mapView.animate(toLocation: targetLocate)
        mapView.animate(toZoom: 11)
//        let zoomCamera = GMSCameraUpdate.setTarget(targetLocate, zoom: 13)
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
        // ⚠️ Cancel ボタンのdispalyをもっと自然なアニメーションに変更するつもり
        // animationと一緒に
        searchBar.setShowsCancelButton(false, animated: true)
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
        
        // requestしてないなら、Viewのclickができないように
        guard requestState else {
            // request 申請後見れますの popup or toastメッセージを表示
            // 方法1: alertを表示
            self.present(setRequestAlert(), animated: true, completion: nil)
            return
        }
        
        // dataをdetailVCに渡す
        detailVC.seatsModelByPlace = resultPlaceModel
        detailVC.searchModelIndex = modelIndex
        
        guard let hasRestauName = cardView.restaurantName.text else {
            return
        }
        
        if let hasImage1 = self.cardView.image1.image {
            detailVC.image1 = hasImage1
        }
        if let hasImage2 = self.cardView.image2.image {
            detailVC.image2 = hasImage2
        }
        if let hasImage3 = self.cardView.image3.image {
            detailVC.image3 = hasImage3
        }
        
        detailVC.restaurantTitle = cardView.restaurantName.text!
        
        // MARK: お気に入りボタンとリクエストボタンのstateを引き渡す
        detailVC.checkStatePlaceDict[hasRestauName] = self.checkStatePlaceDict[hasRestauName]
        
        detailVC.modalPresentationStyle = .fullScreen
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
        
        // keyboardがtrueのときの処理
        if searchBar.showsCancelButton {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        appearKeyboard = false
        print(appearKeyboard)
    }
    
    private func markerConfigure(newLocate locate: CLLocationCoordinate2D) {
//        let position = CLLocationCoordinate2D(latitude: searchPositionLat, longitude: searchPositionLng)
        marker.position = locate
        marker.title = markerTitle
        // markerの色変更
        marker.icon = GMSMarker.markerImage(with: .orange.withAlphaComponent(0.3))
        
        DispatchQueue.main.async {
            self.marker.map = self.mapView
            self.marker.appearAnimation = .pop
        }
    }
    
//    private func setRequestButtonState() {
//        if restauName != "" {
//            if let hasDict = checkStatePlaceDict[self.restauName] {
//                cardView.translatesAutoresizingMaskIntoConstraints  = false
//
//                if hasDict[1] {
//                    // すでにrequestされたものであれば
//                    // heightを0にしてから、topAnchorを調整 -> 無駄なspaceを減らす
//                    cardView.requestButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
//                    cardView.requestButton.topAnchor.constraint(equalTo: cardView.vacancyState.bottomAnchor, constant: 0).isActive = true
//                } else {
//                    // まだ、requestされていない場合の処理
//                }
//            }
//        }
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
    
    private func dismissKeyboardByTap() {
        // どこでもtapしたらkeyboardが表示されないように
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.view.endEditing))
        mapView.addGestureRecognizer(tapGesture)
    }
}

// MARK: Google Map View関連
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
        print("search button clicked!")
        print(searchText)
        
        searchText = hasText
        // search ボタンを押すと、常にkeyboardが表示されないように
        searchBar.endEditing(true)
        
        if isMatchedName() {
            matchAPIDataWithView(target: searchText, index: modelIndex)
            print(checkStateLists)
            // markerを追加してから、変更する方法
            // nil してからまた、入れる
            if marker.map != nil {
                marker.map = nil
            } else {
                marker.map = mapView
            }
            
            print("true: \(restauName)")
            // MARK: 🔥 searchして、ヒットしたらGeoCodingを行う
            getLocation(placeName: restauName, addressName: targetAddress)
        } else {
            // ⚠️nameがmatchしても一回の検索でエラーが表示される問題があった
            // ⚠️ここの検索で一回止まった
            print("no exist search result by search button click")
            // お店の名前と住所を初期化する
            self.restauName = ""
            self.targetAddress = ""
            noHaveSearchResultEvent()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // 今回は、searchControllerで実装してないため、呼び出されないメソッドであることがわかった
        guard let hasText = searchController.searchBar.text else {
            return
        }
        print("update:", hasText)
    }
    
    // TODO: ⚠️途中の段階
    // requestや、likeした複数の場所を最初に全部marker設定
    func setInitMarker() {
        if self.checkStateLists.count == 0 {
            return
        }
        
        for i in 0..<checkStateLists.count {
            if let hasAddress = checkStateLists[i].address {
                
                
                
                
            }
            
            
        }
        
        
        
        let locate = CLLocationCoordinate2D(latitude: defaultPositionLat, longitude: defaultPositionLng)
        marker.position = locate
        marker.title = markerTitle
        // markerの色変更
        marker.icon = GMSMarker.markerImage(with: .orange.withAlphaComponent(0.3))
        
        DispatchQueue.main.async {
            self.marker.map = self.mapView
            self.marker.appearAnimation = .pop
        }
    }
    
    // requestやlikeをしたお店へmarkerを持続的に維持する　もしくは、追加する
    func addAndPreserveMerker() {
        
    }
    

    // search bar touch後、入力を始めたときに呼び出されるメソッド
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !searchBar.showsCancelButton {
            // cancel buttonが表示されていない
            // cancel buttonの表示をanimation効果とともに表す
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        print("search Start!")
    }
    
    // cancel button click時に呼び出されるメソッド
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.showsCancelButton {
            // cancel buttonが表示されている
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        searchBar.endEditing(true)
    }
    
    // 検索入力値が編集されるたびに呼び出されるメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let hasText = searchBar.text else {
            return
        }
        
        print("textDidChange method:", hasText)
    }
    
    func requestApplyTap() {
        cardView.requestButtonState = .requested
        cardView.requestButton.setTitle("リクエスト申請中", for: .normal)
        cardView.requestButton.setTitleColor(.white, for: .normal)
        // backGroundの反映はうまくできた
        cardView.requestButton.backgroundColor = UIColor(rgb: 0xA9A9A9)
//        cardView.requestButton.isEnabled = false
        
        // 実際は、お店側のrequest承諾が必要だが、臨時的にrequest Stateをtrueにする
        requestState = true
        
        // vacancy stateのtext
        cardView.vacancyState.text = "リクエスト承諾をお待ちください"
        cardView.vacancyState.textColor = UIColor(rgb: 0x0000CD)
        
        print("mainPage -> RequestPopVC")
        print("button tapped!")
        // popup viewを出す
        // as castingをしないと、該当のpropertyにアクセス不可
        let requestPopVC = UIStoryboard(name: "RequestPopupVC", bundle: nil).instantiateViewController(withIdentifier: "RequestPopupVC") as! RequestPopupVC
        requestPopVC.modalPresentationStyle = .overCurrentContext
        requestPopVC.modalTransitionStyle = .crossDissolve
        self.present(requestPopVC, animated: true) {
            // 設定した時間後、処理を行う
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if requestPopVC.presentViewState {
                    self.dismiss(animated: true) {
                        // ここで、request thank you Pageを表示したあと、設置リクエストボタンの設定を帰る
                        print("request Okay!")
                    }
                }
            }
        }
    }
    
    func requestCancelTap() {
        self.present(setCancelRequestAlert(), animated: true)
    }
    
}

// MARK: card View関連delegate
extension ViewController: cardViewDelegate {
    func requestButtonEvent() {
        // buttonをクリックすると、リクエスト済みという文字に変更する必要がある
        // buttonクリックしたから、disabledに変える
        // MARK: ⚠️途中の段階, コードリファクタリング
        print("requestState: ", requestState)
        
        if cardView.requestButtonState == .normal {
            // requestがまだの状態 (falseの場合)
            print("normal -> request: ", cardView.requestButtonState)
            requestApplyTap()
        } else {
            // requestをした場合 (申請中)
            print("request -> normal ", cardView.requestButtonState)
            requestCancelTap()
        }
        saveCoreData(checkName: restauName)
    }
    
    func hartButtonEvent() {
        guard let hasRestauName = cardView.restaurantName.text else {
            return
        }
        
        if cardView.hartButtonState == .normal {
            cardView.hartButtonState = .selected
            // MARK: selectedは、trueに
            checkStatePlaceDict[hasRestauName]![1] = true
            cardView.setHartButton()
            cardView.hartButton.layer.add(cardView.bounceAnimation, forKey: nil)
            print("normal -> selected")
        } else {
            cardView.hartButtonState = .normal
            // MARK: normalは、falseに
            checkStatePlaceDict[hasRestauName]![1] = false
            cardView.setHartButton()
            cardView.hartButton.layer.add(cardView.bounceAnimation, forKey: nil)
            print("selected -> normal")
        }
        
        saveCoreData(checkName: restauName)
    }
}

// MARK: Alert 関連
extension ViewController {
    func setRequestAlert() -> UIAlertController {
        let alert = UIAlertController(title: "リクエスト権限エラー", message: "リクエストが必要です。\nリクエストボタンを押して、お店からのリクエスト承諾をお待ちください。", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
            print("alert!")
        }
        alert.addAction(alertAction)
        
        return alert
    }
    
    func setCancelRequestAlert() -> UIAlertController {
        let alert = UIAlertController(title: "リクエストキャンセル", message: "申請中のリクエストを取り消しますか?", preferredStyle: .actionSheet)
        let back = UIAlertAction(title: "戻る", style: .cancel) { _ in
            print("back!")
        }
        
        let cancel = UIAlertAction(title: "取り消し", style: .destructive) { _ in
            self.requestCancelAction()
            print("cancel the request")
        }
        
        alert.addAction(back)
        alert.addAction(cancel)
        
        return alert
    }
    
    func requestCancelAction() {
        cardView.requestButton.backgroundColor = UIColor(rgb: 0xFFBC42)
        cardView.requestButton.setTitle("¥ 設置リクエスト", for: .normal)
        cardView.requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        cardView.requestButton.setTitleColor(.black, for: .normal)
       
        // request状態をまた、trueに
        requestState = false
        cardView.requestButtonState = .normal
        
        // vacancy stateのtext
        cardView.vacancyState.text = "カメラを設置していません"
        cardView.vacancyState.textColor = .black
    }
    
    func setNoResultAlert() -> UIAlertController {
        let alert = UIAlertController(title: "検索結果エラー", message: "入力された名前の場所を見つかりませんでした。", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
            print("No Data!")
        }
        alert.addAction(alertAction)
        
        return alert
    }
    
    func inputAlert() -> UIAlertController {
        let alert = UIAlertController(title: "入力エラー", message: "一文字以上を入力してください。", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確認", style: .default) { _ in
            print("input error!")
        }
        alert.addAction(alertAction)
        
        return alert
    }
}

// MARK: CoreData関連
// ⚠️まだ、途中の段階
// save, update, delete に関する処理が入る予定
extension ViewController {
    // local storageに保存されたものをfetchする間数
    func fetchCoreData() {
        // entityの名前を読み込む
        // <entity名> entity名.fetchRequest()
        let fetchRequest: NSFetchRequest<User_checkStateList> = User_checkStateList.fetchRequest()
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            self.checkStateLists = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    // 検索を通して、一回見てみたことのあるお店であれば、その時点でcore Dataのオブジェクトを生成するようにした
    // targetAddressまで全部駆け込んだ後
    // TODO: 🔥request または、 like buttonをclickしてからcoreDataに保存するようにしたい
    // save したなら、true   してないなら、false
    func saveCoreData(checkName restauName: String) {
        let context = appDelegate.persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "User_checkStateList", in: context) else {
            return
        }
        
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? User_checkStateList else {
            return
        }
        
        // ⚠️それぞれuuidが異なる -> 今後、firebase の authenticationを導入する予定
        // uuidは、データが生成されるたびにuniqueな値が入るようになる
        object.uuid = UUID()
        object.restaurantName = restauName
        object.address = targetAddress
        
        if cardView.requestButtonState == .normal {
            object.request = false
        } else {
            object.request = true
        }
        
        if cardView.hartButtonState == .normal {
            object.like = false
        } else {
            object.like = true
        }
        
        if !object.like && !object.request {
            // 両方ともfalseだったら、coreDataに保存しない
            return
        } else {
            
            appDelegate.saveContext()
            // TODO: ⚠️markerの持続的な保存
        }
        
        
        
        
//        for i in 0..<checkStateLists.count {
//            if checkStateLists[i].restaurantName == restauName {
//                // 同じ名前のrestaurantをすでに格納したのであれば、return
//                return
//            }
//        }
//
//        let index = checkStateLists.count
//        checkStateLists[index].restaurantName = restauName
    }
    
    // 該当のmarkerをclickし、そのCoreDataをアップデートする
    func updateCoreData(checkName restauName: String, index i: Int) {
        guard let hasData = selectedCheckList else {
            return
        }
        
        guard let hasRestauName = hasData.restaurantName else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User_checkStateList> = User_checkStateList.fetchRequest()
        
        // selectしたものだけ読み込む (restaurantの名前を持ってくる)
        fetchRequest.predicate = NSPredicate(format: "restaurantName = %@", hasRestauName)
        
        do {
            // 選択して読み込んだデータ
            // 変更される値のみ、変えてやればいい
            let loadedData = try context.fetch(fetchRequest)
            var hasRequest = loadedData.first?.request
            var hasLike = loadedData.first?.like
            
            if cardView.requestButtonState == .normal {
                hasRequest = false
            } else {
                hasRequest = true
            }
            
            if cardView.hartButtonState == .normal {
                hasLike = false
            } else {
                hasLike = true
            }
            
            // TODO: ⚠️両方ともfalseだったら coreDataから削除
            // contextをdelete -> context をsave
            if !(hasLike!) && !(hasRequest!) {
                let objectToDelete = loadedData.first!
                context.delete(objectToDelete)
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                
            } else {
                appDelegate.saveContext()
            }
            
        } catch {
            print(error)
        }
    }
    
}







// CLUSTER 関連のメソッド
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
//            let lat = searchPositionLat + extent * randomScale()
//            let lng = searchPositionLng + extent * randomScale()
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


