//
//  PeripheralScanInfo.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import CoreBluetooth

/**
 Peripheral 모델
 */
public struct PeripheralScanInfo: Identifiable {
    public let id: UUID
    public let peripheral: CBPeripheral
    public let localName: String
    public let advertisementData: [String: Any]
    public let rssi: Int
    
    init(
        peripheral: CBPeripheral,
        name: String,
        advertisenemtData: [String: Any],
        rssi: NSNumber
    ) {
        self.id = UUID()
        self.peripheral = peripheral
        self.localName = name
        self.advertisementData = advertisenemtData
        self.rssi = rssi.intValue
    }
}


//MARK: - Mapping
public extension PeripheralScanInfo {
    func toUserInfo() -> UserInfo {
        let name = localName.components(separatedBy: "|")[0]
        let description = localName.components(separatedBy: "|")[1]
        return .init(name: name, description: description)
    }
}
