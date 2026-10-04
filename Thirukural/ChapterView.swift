//
//  ChapterView.swift
//  Thirukural
//
//  Created by Anbarasu S on 29/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct ChapterView: View, RandomKuralDataSorce {
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
            //RandomKuralView(randomIndices: getRandomKuralIndexes(forSubSection: selectedSubSection))
            List {

                ForEach(fetchRequest.wrappedValue.indices, id: \.self) { index in
                    NavigationLink(destination: CoupletView(chapter: self.fetchRequest.wrappedValue[index])) {
                        HStack(alignment: .bottom) {
                            Text("\(index+1)")
                                .modifier(IndexLabel())
                            Text("\(self.fetchRequest.wrappedValue[index].chapterTamil)")
                            Spacer()
                            Text(self.indexStringForChapter(self.fetchRequest.wrappedValue[index]))
                                .fontWeight(.medium)
                                .modifier(CoupletRangeLabel())
                        }

                    }
                }
            }
        }


            .navigationBarTitle(Text("\(selectedSubSection.subSectionTamil)")) 
    }

    func indexStringForChapter(_ chapter:CDChapter) -> String {
        let startNumber = chapter.chapterIndex*10-9 as NSNumber
        return commaLessIntegerFormatter.string(from: startNumber)!
    }
}

var commaLessIntegerFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    return formatter
}
