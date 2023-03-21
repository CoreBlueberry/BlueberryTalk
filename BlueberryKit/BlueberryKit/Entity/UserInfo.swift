//
//  UserInfo.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import Foundation

/**
 사용자 정보
 */
public struct UserInfo {
    /**
     이름
     */
    public let name: String
    
    /**
     설명
     */
    public let description: String
    
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}
