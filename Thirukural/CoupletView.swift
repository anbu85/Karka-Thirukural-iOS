//
//  CoupletView.swift
//  Thirukural
//
//  Created by Anbarasu S on 29/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct CoupletView: View {
    private var selectedChapter: CDChapter
    private var fetchRequest: FetchRequest<CDCouplet>

    init(chapter: CDChapter) {
        self.selectedChapter = chapter

        let lastIndex = chapter.chapterIndex*10
        let firsIndex = lastIndex-9

        fetchRequest = FetchRequest<CDCouplet>(
        entity: CDCouplet.entity(),
        sortDescriptors: [NSSortDescriptor(key: "coupletIndex", ascending: true)],
        predicate: NSPredicate(format: "coupletIndex >= %d AND coupletIndex <= %d", firsIndex, lastIndex))
    }

    var body: some View {
        List {

            Section(header: Text("பாயிரம்")) {
                NavigationLink(destination: ExplanationView(vm: ExplanationViewModel(chapter: selectedChapter))) {
                    Text(selectedChapter.payiram)
                    .lineLimit(3)
                }
            }

            Section(header: Text("குறள்")) {
                ForEach(fetchRequest.wrappedValue) { couplet in
                    NavigationLink(destination: ExplanationView(vm: ExplanationViewModel(couplet: couplet))) {
                        HStack(alignment: .bottom) {
                            Text(couplet.coupletTamil)
                            Spacer()
                            Text(commaLessIntegerFormatter.string(for: couplet.coupletIndex)!)
                                .modifier(CoupletRangeLabel())
                        }
                    }
                }
            }

            }.listStyle(GroupedListStyle())
            .navigationBarTitle(Text("\(selectedChapter.chapterTamil)"))
    }
}
