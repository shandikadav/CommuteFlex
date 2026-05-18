//
//  ContentView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 06/05/26.
//

import SwiftUI

struct ContentView: View {
    @State private var router = Router()
    var body: some View {
        TabView(selection: $router.selectedTab) {
            
            // HOME TAB
            NavigationStack(path: $router.homePath) {
                HomeView()
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
}
