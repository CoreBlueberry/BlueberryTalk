//
//  UserRow.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

struct ScanItemRow: View {
    var scanItem: ScanItem
    var userInfo: UserInfo {
        scanItem.userInfo
    }
    var rssi: Int {
        scanItem.rssi
    }
    var rssiText: String {
        "\(rssi)dBm"
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(userInfo.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textNormal)
                
                Text(userInfo.description)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.textDescription)
            }
            Spacer()
            Text(rssiText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primaryBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
