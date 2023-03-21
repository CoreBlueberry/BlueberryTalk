//
//  ContentView.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

struct ChatView: View {
    @EnvironmentObject var bleChatService: BlueberryChatService
    
    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        ForEach(bleChatService.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        .onChange(of: bleChatService.messages.last) { message in
                            guard let id = message?.id else { return }
                            withAnimation {
                                scrollViewProxy.scrollTo(id)
                            }
                        }
                    }
                }
            }
            MessageField()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("🫐 💬 🫐 💬")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("clockwise")
                    bleChatService.disconnect()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
