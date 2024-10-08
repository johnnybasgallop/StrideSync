//
//  HomeView.swift
//  StrideSync
//
//  Created by johnny basgallop on 07/10/2024.
//

import Foundation
import SwiftUI
import HealthKit

var screenWidth = UIScreen.main.bounds.width
var screenHeight = UIScreen.main.bounds.height

struct HomeView : View {
    @EnvironmentObject var viewModel : HomeViewModel
    var body: some View {
        VStack{
            StepsWidget().environmentObject(viewModel)
            HStack{
                DistanceWidget().environmentObject(viewModel)
                Spacer()
            }
        }.onAppear{
            viewModel.fetchDailyStepsAndDistance()
        }
    }
}


#Preview {
    HomeView().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
