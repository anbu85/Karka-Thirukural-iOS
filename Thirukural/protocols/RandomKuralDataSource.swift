//
//  RandomKuralDataSource.swift
//  Thirukural
//
//  Created by Anbarasu S on 30/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import Foundation
import GameplayKit

protocol RandomKuralDataSorce {

}

extension RandomKuralDataSorce {

    /**
    The subsection for which the random kurals has to be displayed

    If - nil - random kurals are generated for the entire range from 1 to 1330
    - else - random kurals are generated for the given sub section
    */
    /*
    func getRandomKuralIndexes(forSubSection subSection:CDSubSection?) -> [Int] {

        if let subSection = subSection {

            if let randomKuralIndexes = getRandomNumbers(amount: 10, from: subSection.childCoupletsIndexRange.firstIndex, to: subSection.childCoupletsIndexRange.lastIndex) as Array<Int>? {

                return randomKuralIndexes

            } else {
                return [100,200,300,400,500,600,700,800,900,1000]
            }

        } else {

            return getRandomNumbers(amount: 10, from: 1, to: 1330) [100,200,300,400,500,600,700,800,900,1000]
        }

    }
     */

    /*
    func getRandomNumbers(amount:Int, from:Int, to:Int) -> [Int] {

        guard (to - from) + 1 >= amount else {
            print("Wrong range and amount is given to generate random numbers")
            return []
        }

        let range = from...to
        var uniqueRandomNumbers:Array<Int> = []

        let timeSeed = UInt64(Date().beginningOfDay().timeIntervalSince1970)
        var generator = RandomGeneratorWithSeed(timeSeed)

        while uniqueRandomNumbers.count < amount {

            let randomNumber = range.randomElement(using: &generator)

            if !uniqueRandomNumbers.contains(randomNumber!) {
                uniqueRandomNumbers.append(randomNumber!)
            }
        }

        print(uniqueRandomNumbers)
        return uniqueRandomNumbers
    }
     */

}

/*
class RandomGeneratorWithSeed: RandomNumberGenerator {

    let seed: UInt64
    private let generator: GKMersenneTwisterRandomSource

    convenience init() {
        self.init(0)
    }

    init(_ seed: UInt64) {
        self.seed = seed
        generator = GKMersenneTwisterRandomSource(seed: seed)
    }

    func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(abs(generator.nextInt(upperBound: Int(upperBound))))
    }

    func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(abs(generator.nextInt()))
    }
}
*/

extension Date {

    func beginningOfDay() -> Date {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day] , from: self)
        return calendar.date(from: components)!
    }

    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        var date = (Calendar.current as NSCalendar).date(byAdding: components, to: self.beginningOfDay(), options: [])!
        date = date.addingTimeInterval(-1)
        return date
    }
}
