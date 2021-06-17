//
//  ContentView.swift
//  prototype
//
//  Created by 이상원 on 2021/06/17.
//

import SwiftUI

struct ContentView: View {
    
    @State var isShowingCameraView = false
    
    @State var showAllBox = false
    @State var filterRatio = 0.5
    
    @State var bookTitle = ""
    
    var body: some View {
        NavigationView {
            VStack{
                
                Spacer()
                
                Image(systemName: "book.circle")
                    .resizable()
                    .frame(width: 150,height: 150)
                
                HStack(){
                    TextField("책 이름을 입력하세요", text: $bookTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(alignment: .center)
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(bookTitle.count==0 ? .black : .blue)
                        .imageScale(.large)
                        .onTapGesture {
                            if bookTitle.count > 0 {
                                self.isShowingCameraView.toggle()
                            }
                        }
                        .sheet(isPresented: $isShowingCameraView, content: {
                            CameraView(
                                bookTitle: self.$bookTitle,
                                showAllBox: self.$showAllBox,
                                filterRatio: self.$filterRatio)
                        })
                    
                } // End of HStack
                .padding(50.0)
                
                Spacer()
                
                NavigationLink(destination: SettingView(showAllBox: self.$showAllBox, filterRatio: self.$filterRatio)){
                    Image(systemName: "ellipsis")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
                .animation(.none)
                
                Spacer()
                
            } // End of VStack
        } // End of NavigationView
    } // End of body
} // End of View

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
