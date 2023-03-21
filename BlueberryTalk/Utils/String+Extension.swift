//
//  String+Extension.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/22.
//

import Foundation

extension String {
    func trim() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    var hasNonEmptyValue: Bool {
        return trim() != ""
    }
}
