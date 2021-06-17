//
//  SettingView.swift
//  prototype
//
//  Created by 이상원 on 2021/06/19.
//

import SwiftUI

struct SettingView: View {
    @Binding var showAllBox: Bool
    @Binding var filterRatio: Double
    
    var body: some View {
            Form{
                Section(header: Text("디버깅")) {
                    Toggle(isOn: $showAllBox){
                        Text("텍스트 박스 전부 표시")
                    }
                } // End of Section
                Section(
                    header: Text("민감도"),
                    content: {
                        HStack{
                            Text("일치")
                            Slider(value: $filterRatio, in: 0.0...2.0)
                            Text("여유")
                        }
                    })
            } // End of Form
            .navigationBarTitle("설정")
    } // End of body
} // End of View

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(showAllBox: .constant(false), filterRatio: .constant(0.5))
    }
}
