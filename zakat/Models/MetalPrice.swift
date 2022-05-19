//
//  File.swift
//  zakat
//
//  Created by Taufiq Ichwanusofa on 11/05/22.
//

import Foundation

struct MetalPriceResponse: Codable {
    let success: Bool
    let timestamp: Int
    let date: String
    let base: String
    let rates: MyData
    let unit: String
//    let userId: Int
//    let id: Int
//    let title: String
//    let body: String
}

struct MyData: Codable {
    let XAG: Double
    let XAU: Double
    let XPD: Double
    let XPT: Double
    let XRH: Double
    
//    let anime_id: Int
//    let anime_name: String
//    let anime_img: String
}
