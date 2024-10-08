import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject var homeViewModel = HomeViewModel(healthStore: HKHealthStore())
    
    var body: some View {
        HomeView().environmentObject(homeViewModel)
    }
}

#Preview {
    ContentView()
}
