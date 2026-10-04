//
//  ThreeButtonView.swift
//  ThirukuralPreviewer
//
//  Created by Anbarasu S on 31/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct ThreeButtonView: View {
    let sections = ["அறம்","பொருள்","இன்பம்"]
    @State var aramToggle = true
    @State var porulToggle = false
    @State var inbamToggle = false
    var body: some View {

        let on1 = Binding<Bool>(get: { self.aramToggle }, set: { self.aramToggle = $0; self.porulToggle = false; self.inbamToggle = false })
        let on2 = Binding<Bool>(get: { self.porulToggle }, set: { self.aramToggle = false; self.porulToggle = $0; self.inbamToggle = false })
        let on3 = Binding<Bool>(get: { self.inbamToggle }, set: { self.aramToggle = false; self.porulToggle = false; self.inbamToggle = $0 })

        return HStack(spacing:10) {
                Toggle(isOn: on1) {
                    Text("அறம்")
                        .fontWeight(.bold)
                    }
                .toggleStyle(ButtonToggleStyle())

                Toggle(isOn: on2) {
                    Text("பொருள்")
                        .fontWeight(.bold)
                }
                .toggleStyle(ButtonToggleStyle())

            Toggle(isOn: on3) {
                Text("இன்பம்")
                    .fontWeight(.bold)
            }
            .toggleStyle(ButtonToggleStyle())


        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}

struct ThreeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ThreeButtonView()
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let textColor = Color(red:0.50, green:0.5, blue:0.5)
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)

    static let lightStart = Color(red:0.96, green:0.94, blue:0.90)
    static let lightEnd = Color(red:0.85, green:0.82, blue:0.74)
}


struct ButtonToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {

        return configuration.label
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))

            .frame(maxWidth: .infinity)
            .foregroundColor(.textColor)
            .background(LinearGradient(gradient: Gradient(colors: [.lightStart, .lightEnd]),
                                       startPoint: configuration.isOn ? .bottom : .top,
                                       endPoint: configuration.isOn ? .top: .bottom))
            .cornerRadius(8)
            .shadow(color: Color.textColor.opacity(0.9), radius: 0.2,
                    x: configuration.isOn ? 1 : 2,
                    y: configuration.isOn ? 1 : 4)
            .shadow(color: Color.textColor.opacity(0.9), radius: 0.1,
                    x: 1,
                    y: configuration.isOn ? 1 : 2)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 236/255, green: 234/255, blue: 235/255), lineWidth: 1)
                .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255), radius: 1.5, x: 2, y: 2)
                .clipShape(
                    RoundedRectangle(cornerRadius: 11)
            )
                .shadow(color: Color.white, radius: 4, x: 2, y: 2)
                .clipShape(
                    RoundedRectangle(cornerRadius: 13)
                )
        )
            .onTapGesture {
                if configuration.isOn == false {
                    configuration.isOn.toggle()
                }
        }
    }
}


extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}



struct RoundedCorners: View {
    var color: Color = .black
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    var body: some View {
        GeometryReader { geometry in
            Path { path in

                let w = geometry.size.width
                let h = geometry.size.height

                // We make sure the redius does not exceed the bounds dimensions
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)

                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                }
                .fill(self.color)
        }
    }
}
