//
//  ScanItem.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import Foundation
import CoreBluetooth
import BlueberryKit

/**
 스캔 목록 모델
 */
struct ScanItem: Identifiable {
    let id: UUID
    
    /**
     사용자 정보
     */
    let userInfo: UserInfo
    
    /**
     rssi
     */
    let rssi: Int
    
    /**
     Peripheral UUID
     */
    let peripheral: CBPeripheral
    
    init(scanInfo: PeripheralScanInfo) {
        self.id = UUID()
        self.userInfo = scanInfo.toUserInfo()
        self.rssi = scanInfo.rssi
        self.peripheral = scanInfo.peripheral
    }
}
