//
//  AdigaramView.swift
//  Thirukural
//
//  Created by Anbarasu S on 08/04/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct AdigaramView: View {
    var title = ""
    var image = "background1"
    var color = Color.textColor
    var shadowColor = Color.textColor

    private let w = 160.0
    private let h = 240.0

    private var selectedChapter: CDChapter
    

    init(chapter: CDChapter) {
        self.selectedChapter = chapter
    }

    var body: some View {
        return ZStack(alignment: .bottomLeading) {

            Image(selectedChapter.imageName)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 180)
                .padding(.bottom, 0)

            LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
            LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)

            VStack(alignment: .leading) {
//            Text("\(selectedChapter.chapterIndex)")
//                .font(.system(size: 12))
//                .foregroundColor(Color.white)
//                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
//                .background(Color.black)
//                .cornerRadius(122)
//                .padding(EdgeInsets(top:8, leading: 8, bottom: 0, trailing: 0))
//                .opacity(0.4)
//                Spacer()
            Text(selectedChapter.chapterTamil)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 12, trailing: 10))
                .lineLimit(2)
            }
        }
        .background(color)
        .cornerRadius(15)
        .frame(width: 130, height: 180)
        .shadow(color: Color.black.opacity(0.6), radius: 10, x: 10, y: 10)
    }
}


