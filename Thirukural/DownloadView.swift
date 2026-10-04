//
//  DownloadView.swift
//  Thirukural
//
//  Created by Anbarasu S on 30/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI
import CoreData

struct DownloadView: View, CloudKitToCoreDataHandler {

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(fetchRequest: CDSection.allObjectsFetchRequest()) private var sections: FetchedResults<CDSection>
    @FetchRequest(fetchRequest: CDSubSection.allObjectsFetchRequest()) private var subSections: FetchedResults<CDSubSection>
    @FetchRequest(fetchRequest: CDChapter.allObjectsFetchRequest()) private var chapters: FetchedResults<CDChapter>
    @FetchRequest(fetchRequest: CDCouplet.allObjectsFetchRequest()) private var couplets: FetchedResults<CDCouplet>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("பதிவிறக்கம்").font(.largeTitle).fontWeight(.bold)

            HStack {
                VStack(alignment: .leading) {
                    Text(ThirukuralCloudKitRecordType.CKSection.tamilName).modifier(PrimaryLabel())
                    Text("\(sections.count) / \(ThirukuralCloudKitRecordType.CKSection.maxCount)").modifier(SecondaryLabel())
                }
                Spacer()
                if sections.count == ThirukuralCloudKitRecordType.CKSection.maxCount {
                    checkmarkView().onAppear() {
                        self.checkAndDismiss()
                    }
                } else {
                    activityIndicator()
                }

            }

            HStack {
                VStack(alignment: .leading) {
                    Text(ThirukuralCloudKitRecordType.CKSubSection.tamilName).modifier(PrimaryLabel())
                    Text("\(subSections.count) / \(ThirukuralCloudKitRecordType.CKSubSection.maxCount)").modifier(SecondaryLabel())
                }
                Spacer()
                if subSections.count == ThirukuralCloudKitRecordType.CKSubSection.maxCount {
                    checkmarkView().onAppear() {
                        self.checkAndDismiss()
                    }
                } else {
                    activityIndicator()
                }

            }


            HStack {
                VStack(alignment: .leading) {
                    Text(ThirukuralCloudKitRecordType.CKChapter.tamilName).modifier(PrimaryLabel())
                    Text("\(chapters.count) / \(ThirukuralCloudKitRecordType.CKChapter.maxCount)").modifier(SecondaryLabel())
                }
                Spacer()
                if chapters.count == ThirukuralCloudKitRecordType.CKChapter.maxCount {
                    checkmarkView().onAppear() {
                        self.checkAndDismiss()
                    }
                } else {
                    activityIndicator()
                }

            }

            HStack {
                VStack(alignment: .leading) {
                    Text(ThirukuralCloudKitRecordType.CKCouplet.tamilName).modifier(PrimaryLabel())
                    Text("\(couplets.count) / \(ThirukuralCloudKitRecordType.CKCouplet.maxCount)").modifier(SecondaryLabel())
                }
                Spacer()
                if couplets.count == ThirukuralCloudKitRecordType.CKCouplet.maxCount {
                    checkmarkView().onAppear() {
                        self.checkAndDismiss()
                    }
                } else {
                    activityIndicator()
                }

            }

        }.frame(width: 180)

    }

    func checkmarkView() -> some View {
        return Image(systemName: "checkmark").foregroundColor(.accentColor)
    }

    func activityIndicator() -> some View {
        return ActivityIndicator(isAnimating: .constant(true), style: .medium)
    }

    func checkAndDismiss() {
        guard sections.count == ThirukuralCloudKitRecordType.CKSection.maxCount else { return }
        guard subSections.count == ThirukuralCloudKitRecordType.CKSubSection.maxCount else { return }
        guard chapters.count == ThirukuralCloudKitRecordType.CKChapter.maxCount else { return }
        guard couplets.count == ThirukuralCloudKitRecordType.CKCouplet.maxCount else { return }

        self.presentationMode.wrappedValue.dismiss()
    }

}


struct SecondaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
    }
}

struct PrimaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)

    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}



struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView()
    }
}
