// UsersListView.swift

// UsersListView.swift

// UsersListView.swift

import SwiftUI

struct UsersListView: View {
    @State private var viewModel: UsersViewModel

    init(viewModel: UsersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            UsersStateView(state: viewModel.state, retry: reload)
                .navigationTitle("Users")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Refresh", systemImage: "arrow.clockwise", action: reload)
                            .disabled(viewModel.isLoading)
                    }
                }
                .task {
                    await viewModel.load()
                }
        }
    }

    private func reload() {
        Task {
            await viewModel.load()
        }
    }
}

// MARK: - State

private struct UsersStateView: View {
    let state: UsersState
    let retry: () -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't Load Users", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again", action: retry)
                    .buttonStyle(.borderedProminent)
            }

        case .loaded(let users) where users.isEmpty:
            ContentUnavailableView("No Users", systemImage: "person.2.slash")

        case .loaded(let users):
            List(users) { user in
                UserRow(user: user)
            }
        }
    }
}

// MARK: - Row

private struct UserRow: View {
    let user: User

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(user.name)
                .font(.headline)
            Text(user.email)
                .font(.subheadline)
            Text(user.companyName)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

