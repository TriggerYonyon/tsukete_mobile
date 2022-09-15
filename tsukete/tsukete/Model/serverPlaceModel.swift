//
//  serverPlaceModel.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/14.
//

import Foundation

// Place Model API

struct PlaceModel: Codable {
    // idは今回未使用
    let id: String?
    // restaurantName
    let name: String?
    //　郵便番号
    let zipcode: String?
    // 住所
    let prefecture: String?
    let locality: String?
    let street: String?
    // building
    let building: String?
    
    // 利用施設の案内
    let hasParking: Bool?
    let nonSmoking: Bool?
    // image写真
    let imageUrl: String?
    // 座席情報
    let seats: [SeatsInfo]
    let registerdAt: String?
}

struct SeatsInfo: Codable {
    let id: String?
    // テーブルかカウンターか
    let type: String?
    // 座席数
    let capacity: Int?
    // コンセントの席であるか
    let hasOutlet: Bool?
    // エアコンの近くか
    let isNearAirConditioner: Bool?
    // 空席かないか
    let isUsed: Bool?
    let registeredAt: String?
}
