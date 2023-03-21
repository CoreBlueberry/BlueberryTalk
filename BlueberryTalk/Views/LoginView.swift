//
//  LoginView.swift
//  BlueberryTalk
//
//  Created by 허성진 on 2023/03/13.
//

import SwiftUI
import Combine
import BlueberryKit


struct LoginView: View {
    @EnvironmentObject var bleChatService: BlueberryChatService
    
    @State var nameInput: String = ""
    let maxLength = 5
    
    @State var descriptionInput: String = EmojiData.emojis.first ?? "🫐"
    var isValid: Bool {
        return nameInput.hasNonEmptyValue && descriptionInput.hasNonEmptyValue
    }
    var buttonForegroundColor: Color {
        isValid ? Color.textWhite : Color.textDescription
    }
    var buttonBackgroundColor: Color {
        isValid ? Color.primaryBlue : Color.backgroundField
    }
    
    @State private var isShowingEmojiPicker = false
    
    var body: some View {
        VStack {
            NavigationLink(
                "",
                destination: ScanView(),
                isActive: $bleChatService.isPeripheralManagerOn
            )
            .frame(width: 0, height: 0)
            
            VStack() {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("appLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    VStack(spacing: 8) {
                        Text("블루베리톡🫐")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.textNormal)
                        Text("블루투스로 채팅하기")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.textSubtitle)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    TextField("이름을 입력해주세요 (5자 이내)", text: $nameInput)
                        .onReceive(Just(nameInput)) { newValue in
                            if newValue.count > maxLength {
                                nameInput = String(newValue.prefix(maxLength))
                            }
                        }
                        .textFieldStyle(BasicTextFieldStyle())
                        .keyboardType(.default)
                    HStack() {
                        Text(descriptionInput)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .font(.system(size: 24.0, weight: .regular))
                            .foregroundColor(.textNormal)
                            .background(Color.backgroundField)
                            .cornerRadius(8)
                        
                        Button(action: {
                            isShowingEmojiPicker = true
                        }, label: {
                            Text("Emoji 변경하기")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .font(.system(size: 16.0, weight: .medium))
                                .foregroundColor(.primaryBlue)
                                .background(Color.primaryLightBlue)
                                .cornerRadius(8)
                        })
                    }
                    .sheet(isPresented: $isShowingEmojiPicker) {
                        EmojiPicker(selectedEmoji: $descriptionInput)
                    }
                }
                
                Spacer()
                Spacer()
                Spacer()
            }
            
            VStack {
                Button(action: {
                    hideKeyboard()
                    
                    let userInfo = UserInfo(name: nameInput, description: descriptionInput)
                    bleChatService.startAdvertising(userInfo: userInfo)
                    bleChatService.startScan()
                }, label: {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .font(.system(size: 16.0, weight: .medium))
                        .foregroundColor(buttonForegroundColor)
                        .background(buttonBackgroundColor)
                        .cornerRadius(8)
                })
                .disabled(!isValid)
            }
            .frame(alignment: .bottom)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
