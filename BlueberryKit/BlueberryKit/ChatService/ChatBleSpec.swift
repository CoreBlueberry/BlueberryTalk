//
//  ChatBleSpec.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import CoreBluetooth

struct ChatBleSpec {
    /// Service UUID
    static let serviceUUID = CBUUID(string: "3225090F-38C9-4603-9155-8096527A5565")
    
    /// Characteristic UUID
    static let rxUUID = CBUUID(string: "4407CD6A-8637-449C-B54C-E88C82D62973")
    static let rxProperties: CBCharacteristicProperties = .write
    static let rxPermissions: CBAttributePermissions = .writeable
}
