//
//  CBManagerState+Ext.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import CoreBluetooth

extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .poweredOn: return "Powered ON"
        case .poweredOff: return "Powered OFF"
        case .resetting: return "Resetting"
        case .unauthorized: return "Unauthorized"
        case .unsupported: return "Unsupported"
        default: return "Unknown"
        }
    }
}
