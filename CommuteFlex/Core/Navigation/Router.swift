//
//  Router.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 18/05/26.
//

import SwiftUI

@Observable
final class Router{
    var selectedTab: AppTab = .home
    
    enum AppTab {
        case home
        case stats
        case profile
    }
    
    var homePath: [HomeDestination] = []
    var statsPath: [StatsDestination] = []
    var profilePath: [ProfileDestination] = []
    
    enum HomeDestination: Hashable {
        
    }
    
    enum StatsDestination: Hashable {
        
    }
    
    enum ProfileDestination: Hashable {
        
    }
    
    func popToRoot(from tab: AppTab) {
        switch tab {
        case .home: homePath.removeAll()
        case .stats: statsPath.removeAll()
        case .profile: profilePath.removeAll()
        }
    }
    
    func resetAllPath() {
        homePath.removeAll()
        statsPath.removeAll()
        profilePath.removeAll()
    }
}
