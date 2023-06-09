//
//  MessageField.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

struct MessageField: View {
    @EnvironmentObject var bleChatService: BlueberryChatService
    @State private var message = ""
    
    var isValid: Bool {
        return message.hasNonEmptyValue
    }
    var buttonForegroundColor: Color {
        isValid ? Color.textWhite : Color.textDescription
    }
    var buttonBackgroundColor: Color {
        isValid ? Color.primaryBlue : Color.backgroundField
    }
    
    var body: some View {
        HStack {
            CustomTextField(
                placeholder: Text("메세지를 입력하세요"),
                text: $message
            )
            
            Button {
                bleChatService.sendMessage(text: message)
                message = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .padding(10)
                    .foregroundColor(buttonForegroundColor)
                    .background(buttonBackgroundColor)
                    .cornerRadius(50)
            }
            .disabled(!isValid)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.backgroundField)
        .cornerRadius(50)
        .padding()
    }
}

struct MessageField_Previews: PreviewProvider {
    static var previews: some View {
        MessageField()
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = {}
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.textPlaceholder)
            }
            
            TextField(
                "",
                text: $text,
                onEditingChanged: editingChanged,
                onCommit: commit
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(.textNormal)
        }
    }
}
