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
public class PeripheralScanInfo: Identifiable {
    public let id: UUID
    public let peripheral: CBPeripheral
    private(set) var localName: String
    private(set) var advertisementData: [String: Any]
    public private(set) var rssi: Int
    
    init(
        peripheral: CBPeripheral,
        localName: String,
        advertisenemtData: [String: Any],
        rssi: NSNumber
    ) {
        self.id = UUID()
        self.peripheral = peripheral
        self.localName = localName
        self.advertisementData = advertisenemtData
        self.rssi = rssi.intValue
    }
    
    func update(
        localName: String,
        advertisenemtData: [String: Any],
        rssi: NSNumber
    ) {
        self.localName = localName
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
