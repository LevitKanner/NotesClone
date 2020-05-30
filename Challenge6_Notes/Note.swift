//
//  Note.swift
//  Challenge6_Notes
//
//  Created by Levit Kanner on 30/05/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import Foundation

struct Note: Identifiable, Codable {
    let id = UUID()
    let text: String
    var title: String {
        text.components(separatedBy: "\n").first ?? ""
    }
}
