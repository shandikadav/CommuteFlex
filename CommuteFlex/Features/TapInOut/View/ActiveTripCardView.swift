//
//  ActiveTripCardView.swift
//  CommuteFlex
//
//  Created by Shandika David Ardiansyah.
//
import SwiftUI
import Combine

/// A banner card displayed on HomeView when a trip is in progress.
struct ActiveTripCardView: View {
    let activeTrip: ActiveTrip
    var onTapOut: () -> Void
    var onCancel: () -> Void

    @State private var elapsed: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // MARK: - Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                    .shadow(color: .green.opacity(0.5), radius: 4)

                Text("In Transit")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)

                Spacer()

                Text(formattedElapsed)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            // MARK: - Route info
            HStack(spacing: 12) {
                Image(systemName: activeTrip.transportType.iconName)
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(activeTrip.departureStation)
                        .font(.body.weight(.semibold))

                    Text(activeTrip.transportType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                Text("?")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            // MARK: - Tap Out button
            HStack {
                Button(action: onTapOut) {
                    Label("Tap Out", systemImage: "wave.3.left")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.regular)

                Menu {
                    Button("Cancel Trip", role: .destructive, action: onCancel)
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("More trip actions")
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.green.opacity(0.3), lineWidth: 1)
        )
        .onReceive(timer) { _ in
            elapsed = Date.now.timeIntervalSince(activeTrip.departureTime)
        }
        .onAppear {
            elapsed = Date.now.timeIntervalSince(activeTrip.departureTime)
        }
    }

    private var formattedElapsed: String {
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return String(format: "%dh %02dm", hours, mins)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }
}
