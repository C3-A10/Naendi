//
//  coba.swift
//  Naendi
//
//  Created by Dwinda Audia Irnaonefa on 16/07/26.
//

//
//  MyProfileView.swift
//  IntroduceMyself2026
//
//  Created by Amelia Alexandra on 14/07/26.
//

import SwiftUI

struct MyProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image("MyImage")
                    .resizable()
                    .frame(width: 170, height: 170)
                    .clipShape(Circle())
                
                Text("Sore Hari")
                    .font(.system(size: 22))
                    .bold()
                    .padding(.bottom)
                
                HStack {
                    Spacer()
                    VStack {
                        Text("SCHOOL")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 1)
                        Text("SMAK St. Louis 1")
                            .font(.system(size: 17))
                    }
                    Spacer()
                    Divider()
                        .frame(height: 30)
                    Spacer()
                    VStack {
                        Text("GRADE")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 1)
                        Text("XII")
                            .font(.system(size: 17))
                    }
                    Spacer()
                    Divider()
                        .frame(height: 30)
                    Spacer()
                    VStack {
                        Text("MAJOR")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 1)
                        Text("Science")
                            .font(.system(size: 17))
                    }
                    Spacer()
                }
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
                NavigationLink {
                    
                } label: {
                    Text("More About Me")
                }
                .padding()
                Spacer()
            }
            .padding()
            .navigationTitle("My Profile")
        }
    }
}

#Preview {
    MyProfileView()
}
