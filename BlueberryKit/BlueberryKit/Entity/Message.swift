//
//  Message.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import Foundation

/**
 메세지
 */
public struct Message: Identifiable, Hashable {
    public let id: UUID
    
    public let text: String
    public let received: Bool
    public let timestamp: Date
    
    init(text: String, received: Bool, timestamp: Date) {
        self.id = UUID()
        self.text = text
        self.received = received
        self.timestamp = timestamp
    }
}
