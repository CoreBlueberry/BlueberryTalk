//
//  EmojiPicker.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/22.
//

import SwiftUI

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    
    var body: some View {
        VStack {
            Text("Emoji를 선택해주세요")
                .font(.headline)
                .foregroundColor(.textNormal)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))]) {
                    ForEach(EmojiData.emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct EmojiData {
    static let emojis = [
        "🫐", "🚀", "❤️", "✨", "👍", "🙏",
        "😀", "😆", "😁", "🥹", "😂",
        "😍", "🥰", "🤩", "😘", "😚",
        "🤔", "🤯", "😱", "🧐", "😵‍💫",
        "🥳", "😴", "🥱", "😷", "😳",
        "🤒", "🥴", "🤕", "🤧"
    ]
}
