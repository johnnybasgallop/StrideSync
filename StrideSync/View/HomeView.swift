import SwiftUI
import HealthKit

var screenWidth = UIScreen.main.bounds.width
var screenHeight = UIScreen.main.bounds.height

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        List {
            VStack(spacing: 10) {
                StepsWidget().environmentObject(viewModel)
                
                HStack(spacing: 10) {
                    DistanceWidget().environmentObject(viewModel)
                    FlightsWidget().environmentObject(viewModel)
                }
                .padding(.horizontal)
                
                StepComparisonView().environmentObject(viewModel)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
        }
        .frame(width: screenWidth)
        .scrollContentBackground(.hidden)
        .refreshable {
            viewModel.fetchDailyData()
        }
        .onAppear {
            viewModel.fetchDailyData()
        }
    }
}

#Preview {
    HomeView().environmentObject(HomeViewModel(healthStore: HKHealthStore()))
}
