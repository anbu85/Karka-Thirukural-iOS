//
//  PaalView.swift
//  Thirukural
//
//  Created by Anbarasu S on 08/04/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct PaalView: View {
    private var selectedSection: CDSection
    private var fetchRequest: FetchRequest<CDSubSection>
    init(section: CDSection) {
        selectedSection = section
        fetchRequest = FetchRequest<CDSubSection>(
            entity: CDSubSection.entity(),
            sortDescriptors: [NSSortDescriptor(key: "subSectionIndex", ascending: true)],
            predicate: NSPredicate(format: "parentSection = %@", section.recordName))
    }

    var body: some View {
        VStack {

            // section header

            HStack {
                Text(selectedSection.sectionTamil)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(EdgeInsets(top: 15, leading: 20, bottom: 0, trailing: 20))

                Spacer()
            }

            // insert payiram button

            if selectedSection.payiram.count > 1 {
                NavigationLink(destination: ExplanationView(vm: ExplanationViewModel(section: selectedSection))) {
                    Text(selectedSection.payiram)
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

            // insert iyal views for section - for each

            ForEach(fetchRequest.wrappedValue) { subSection in
                IyalView(subSection: subSection)
            }
            
        }
    }
}


