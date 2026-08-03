//
//  ContentView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 06/05/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var router = Router()

    var body: some View {
        TabView(selection: $router.selectedTab) {

            // HOME TAB
            NavigationStack(path: $router.homePath) {
                HomeView()
                    .navigationDestination(for: Router.HomeDestination.self) {
                        destination in
                        switch destination {
                        case .tripDetail(let trip):
                            TripDetailView(trip: trip)
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Router.AppTab.home)

            // STATS TAB
            NavigationStack(path: $router.statsPath) {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar.fill")
            }
            .tag(Router.AppTab.stats)

            // PROFILE TAB
            NavigationStack(path: $router.profilePath) {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(Router.AppTab.profile)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Trip.self, inMemory: true)
}
