//
//  MonthlyRecapView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//

import SwiftData
import SwiftUI

struct StatisticsShareView: View {
    let periodTitle: String
    let trips: [Trip]

    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = StatsViewModel()
    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Card Preview

                    recapCard
                        .scaleEffect(0.85)
                        .frame(height: 590) // Scaled visual height

                    // MARK: - Share Button

                    if let image = renderedImage {
                        ShareLink(
                            item: Image(uiImage: image),
                            preview: SharePreview(
                                "My \(periodTitle) Commute Statistics",
                                image: Image(uiImage: image)
                            )
                        ) {
                            Label("Share Statistics", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.tint)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 24)
                    }

                    Text("Share this commute statistics card to Instagram, Messages, or another app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                renderImage()
            }
        }
    }

    // MARK: - Card

    private var recapCard: some View {
        MonthlyRecapCardView(
            periodTitle: periodTitle,
            totalTrips: trips.count,
            mostUsedTransport: viewModel.mostUsedTransportType(from: trips),
            topStation: viewModel.mostVisitedStation(from: trips),
            topCorridor: viewModel.mostUsedCorridorOrLine(from: trips),
            totalDistance: viewModel.formattedDistance(from: trips),
            totalSpending: viewModel.formattedSpending(from: trips),
            transportBreakdown: viewModel.transportBreakdown(from: trips),
            hasDistance: viewModel.totalEstimatedDistance(from: trips) > 0,
            hasSpending: viewModel.totalEstimatedSpending(from: trips) > 0
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    // MARK: - Render

    private func renderImage() {
        renderedImage = viewModel.renderStatisticsImage(for: trips, periodTitle: periodTitle)
    }
}

#Preview {
    StatisticsShareView(
        periodTitle: "All Time",
        trips: []
    )
}
