//
//  CommuteFlexApp.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 06/05/26.
//

import SwiftData
import SwiftUI

@main
struct CommuteFlexApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Trip.self)
    }
}
