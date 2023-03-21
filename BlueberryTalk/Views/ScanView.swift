//
//  ScanView.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

struct ScanView: View {
    @EnvironmentObject var bleChatService: BlueberryChatService
    
    @State private var rotationAngle = Angle(degrees: 0)
    
    var body: some View {
        ZStack {
            NavigationLink(
                "",
                destination: ChatView(),
                isActive: $bleChatService.isPeripheralConnected
            )
            .frame(width: 0, height: 0)
            
            List {
                PeripheralCells()
            }
            .listStyle(.plain)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("사용자 스캔")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("로그아웃")
                    bleChatService.endAdvertising()
                } label: {
                    Text("로그아웃")
                        .foregroundColor(.secondaryRed)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    print("clockwise")
                    rotationAngle = Angle(degrees: 0)
                    withAnimation {
                        self.rotationAngle = Angle(degrees: 360)
                    }
                    
                    bleChatService.startScan()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(rotationAngle)
                }
            }
        }
    }
    
    struct PeripheralCells: View {
        @EnvironmentObject var bleChatService: BlueberryChatService
        
        var body: some View {
            ForEach(0..<bleChatService.discoveredPeripheral.count, id: \.self) { index in
                let scanInfo = bleChatService.discoveredPeripheral[index]
                let scanItem = ScanItem(scanInfo: scanInfo)
                Button(action: {
                    let peripheral = scanItem.peripheral
                    bleChatService.connect(peripheral: peripheral)
                }) {
                    ScanItemRow(scanItem: scanItem)
                }
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
