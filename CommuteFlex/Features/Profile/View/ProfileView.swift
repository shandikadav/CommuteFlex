//
//  ProfileView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah on 18/05/26.
//

import SwiftData
import SwiftUI

struct ProfileView: View {
    @Query private var trips: [Trip]

    @State private var viewModel = ProfileViewModel()

    var body: some View {
        List {

            Section {
                HStack {
                    Image(systemName: "tram.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.tint)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TransitLog")
                            .font(.headline)

                        Text("Personal Transit Journal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Your Data") {
                HStack {
                    Label("Total Trips", systemImage: "number")
                    Spacer()
                    Text("\(trips.count)")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Transport Types Used", systemImage: "bus.fill")
                    Spacer()
                    Text("\(viewModel.uniqueTransportTypes(from: trips))")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Stations Visited", systemImage: "mappin")
                    Spacer()
                    Text("\(viewModel.uniqueStations(from: trips))")
                        .foregroundStyle(.secondary)
                }
            }

            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Storage", systemImage: "internaldrive")
                    Spacer()
                    Text("On Device")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: Trip.self, inMemory: true)
}
