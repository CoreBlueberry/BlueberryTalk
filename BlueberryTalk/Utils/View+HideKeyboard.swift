//
//  View+HideKeyboard.swift
//  BlueberryTalk
//
//  Created by Heo on 2023/03/20.
//

import UIKit
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
