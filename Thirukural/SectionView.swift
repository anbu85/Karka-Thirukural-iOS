//
//  SectionView.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI
import CoreData

struct AppRootView: View {
    @StateObject private var videoPlayer = YouTubePlayerController()

    var body: some View {
        SectionView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing) {
                if let activeVideo = videoPlayer.activeVideo {
                    FloatingYouTubePlayer(
                        video: activeVideo,
                        onClose: videoPlayer.close
                    )
                    .padding(16)
                }
            }
        .environmentObject(videoPlayer)
    }
}

struct SectionView: View, CloudKitToCoreDataHandler, CloudKitOperator, RandomKuralDataSorce {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: CDSection.allObjectsFetchRequest()) private var sections: FetchedResults<CDSection>
    @State var showingModal = false

    @State private var selectedSection: CDSection?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 5.0) {

                    ForEach(self.sections) { section in
                        PaalView(section: section)
                    }
                }
//                .background(Color(hex: "#EAE7D8"))
            }
            .navigationBarTitle(Text("திருக்குறள்")) // Default to large title style

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if self.isInitialDataFromCloudKitDownloadedtoMOC(self.managedObjectContext) == false {
                self.startDownloadingRecords(managedObjectContext: self.managedObjectContext)
                self.showingModal = true
            }
        }.sheet(isPresented: self.$showingModal) { 
            DownloadView().environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
}

struct SubSectionView: View {
    private var fetchRequest: FetchRequest<CDSubSection>
    init(section: CDSection) {
        fetchRequest = FetchRequest<CDSubSection>(
            entity: CDSubSection.entity(),
            sortDescriptors: [NSSortDescriptor(key: "subSectionIndex", ascending: true)],
            predicate: NSPredicate(format: "parentSection = %@", section.recordName))
    }
    var body: some View {
        List {
            ForEach(fetchRequest.wrappedValue.indices, id: \.self) { index in
                NavigationLink(destination: ChapterView(subSection: self.fetchRequest.wrappedValue[index])) {

                    HStack {
                        Text("\(index+1)").modifier(IndexLabel())
                        Text(self.fetchRequest.wrappedValue[index].subSectionTamil)
                        Spacer()
                        Text(self.fetchRequest.wrappedValue[index].coupletRange).modifier(CoupletRangeLabel())
                    }
                }
            }
        }
    }


}

struct IndexLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .foregroundColor(.black)
            .frame(width: 25, height: 25)
            .background(Color(.sRGB, red: 0.59, green: 0.62, blue: 0.63, opacity: 1.0))
            .cornerRadius(6)
    }
}

struct CoupletRangeLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
            .foregroundColor(.red)
            .padding(.trailing, 20)
    }
}



struct SectionView_Previews: PreviewProvider {
    static var previews: some View {
        SectionView()
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
