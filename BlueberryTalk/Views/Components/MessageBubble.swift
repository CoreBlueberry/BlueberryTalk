//
//  MessageBubble.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/12.
//

import SwiftUI
import BlueberryKit

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: message.received ? .leading : .trailing) {
            HStack {
                Text(message.text)
                    .padding()
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(message.received ? .textNormal : .textWhite)
                    .background(message.received ? Color.backgroundField : Color.primaryBlue)
                    .cornerRadius(16)
            }
            .frame(maxWidth: 300, alignment: message.received ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.received ? .leading : .trailing, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.received ? .leading : .trailing)
        .padding(message.received ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

//struct MessageBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageBubble(
//            message: Message(
//                text: "안녕하세요 허성진입니다. 저는 지금 CoreBluetooth를 소개하기 위해 블루베리톡이라는 앱을 만들고 있습니다.",
//                received: false,
//                timestamp: Date()
//            )
//        )
//    }
//}
