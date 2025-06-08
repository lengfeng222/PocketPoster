//
//  OnBoardingView.swift
//  Pocket Poster
//
//  Created by lemin on 5/31/25.
//

import SwiftUI

struct OnBoardingView: View {
    let cards: [OnBoardingPage]
    
    @Binding var isFinished: Bool
    @State var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            OnBoardingCardView(info: cards[currentIndex], pageCount: cards.count, idx: $currentIndex, isFinished: $isFinished)
        }
    }
}
