//
//  RandomKuralView.swift
//  Thirukural
//
//  Created by Anbarasu S on 30/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import SwiftUI

struct RandomKuralView: View, RandomKuralDataSorce {

    private var fetchRequest: FetchRequest<CDCouplet>

    init(randomIndices: [Int]) {
        fetchRequest = FetchRequest<CDCouplet>(
        entity: CDCouplet.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "ANY coupletIndex IN %@", randomIndices))
    }
    
    var body: some View {
        GeometryReader { geometry in

            ScrollView(.horizontal) {
                HStack {
                    ForEach(self.fetchRequest.wrappedValue) { couplet in
                            ZStack(alignment: .bottomTrailing) {
                                Text(couplet.coupletTamil)
                                Spacer()
                                Text(commaLessIntegerFormatter.string(for: couplet.coupletIndex)!)
                                    .modifier(CoupletRangeLabel())
                            }
                            .background(Color.white)
                            .padding(.leading,10)
                    }
                }
            }.frame(width: geometry.size.width, height: 80)
            .background(Color.gray)
        }

    }
}

//struct RandomKuralView_Previews: PreviewProvider {
//    static var previews: some View {
//        RandomKuralView()
//    }
//}
