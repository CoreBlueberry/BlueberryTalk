//
//  BlueberryTalkApp.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

@main
struct BlueberryTalkApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BlueberryChatService())
        }
    }
}
