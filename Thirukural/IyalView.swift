//
//  IyalView.swift
//  Thirukural
//
//  Created by Anbarasu S on 08/04/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct IyalView: View {
    private var selectedSubSection: CDSubSection
    private var fetchRequest: FetchRequest<CDChapter>

    init(subSection: CDSubSection) {
        self.selectedSubSection = subSection
        fetchRequest = FetchRequest<CDChapter>(
        entity: CDChapter.entity(),
        sortDescriptors: [NSSortDescriptor(key: "chapterIndex", ascending: true)],
        predicate: NSPredicate(format: "parentSubSection = %@", subSection.recordName))
    }

    var body: some View {
        VStack {
            HStack {
                Text(selectedSubSection.subSectionTamil)
                .font(.title)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                Spacer()
            }

            if selectedSubSection.payiram.count > 1 {
                NavigationLink(destination: ExplanationView(vm: ExplanationViewModel(subSection: selectedSubSection))) {
                    Text(selectedSubSection.payiram)
                        .font(.system(size: 15))
                        .lineLimit(3)
                        .frame(height: 60)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .foregroundColor(Color.textColor)
                        .background(Color(.systemGray5))
                        .cornerRadius(15)
                        .padding(EdgeInsets(top: 15, leading: 13, bottom: 0, trailing: 20))
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(fetchRequest.wrappedValue) { chapterr in
                        NavigationLink(destination: CoupletView(chapter: chapterr)) {

                            AdigaramView(chapter: chapterr)

                        }
                    }
                }.padding(EdgeInsets(top: 15, leading: 20, bottom: 20, trailing: 20))

            }


        }
    }
}

