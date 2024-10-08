//
//  DistanceWidget.swift
//  StrideSync
//
//  Created by johnny basgallop on 08/10/2024.
//

import SwiftUI
import HealthKit

struct DistanceWidget: View {
    @EnvironmentObject var viewModel : HomeViewModel
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(.brandBlue)
                .frame(width: (screenWidth - 40) / 2, height: 175)
            
            VStack(alignment: .leading,spacing: 10){
                Text("Distance Covered")
                    .foregroundStyle(.brandCharcoal)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                HStack{
                    Text("\(viewModel.distance)")
                        .foregroundStyle(.brandCharcoal)
                        .font(.system(size: 60, weight: .semibold))
                    Spacer()
                    Image(systemName: "shoeprints.fill")
                        .font(.system(size: 35))
                        .foregroundStyle(.brandCharcoal)
                }
            }
            .frame(width: (screenWidth - 40) / 2, height: 175)
            .padding()
        }.padding()
    }
}

#Preview {
    DistanceWidget().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
