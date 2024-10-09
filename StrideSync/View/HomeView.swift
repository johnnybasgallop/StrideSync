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
            }
            .listRowBackground(Color.clear) // Make each row's background transparent
            .listRowInsets(EdgeInsets()) // Remove default List insets to get full-width VStack
        }
        .scrollContentBackground(.hidden) // Hide the overall List background
        .refreshable { // Use refreshable with List
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
