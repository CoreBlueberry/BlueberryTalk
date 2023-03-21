//
//  SplashView.swift
//  BlueberryTalk
//
//  Created by Heo on 2023/03/20.
//

import SwiftUI

struct SplashView: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        if self.isActive {
            NavigationView {
                LoginView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            ZStack {
                VStack {
                    Image("appLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                
                VStack {
                    Spacer()
                    Text("ⓒ Lucas Heo. All Rights Reserved.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.textDescription)
                }
                .padding(.bottom, 72)
                .frame(alignment: .bottom)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
