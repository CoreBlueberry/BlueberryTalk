//
//  BasicTextFieldStyle.swift
//  BlueberryTalk
//
//  Created by Heo on 2023/03/20.
//

import Foundation
import SwiftUI

struct BasicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .font(.system(size: 16.0, weight: .regular))
            .foregroundColor(.textNormal)
            .background(Color.backgroundField)
            .cornerRadius(8)
    }
}
