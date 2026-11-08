// UsersViewModelTests.swift

import Foundation
import Testing
@testable import UserApp

@MainActor
struct UsersViewModelTests {
    private let users = [
        User.fixture(id: 1, name: "Leanne Graham"),
        User.fixture(id: 2, name: "Ervin Howell")
    ]

    // MARK: - Initial load

    @Test func startsIdle() {
        let sut = UsersViewModel(repository: UsersRepositoryStub(result: .success([])))

        #expect(sut.state == .idle)
        #expect(!sut.isLoading)
    }

    @Test func loadSuccessShowsUsers() async {
        let repository = UsersRepositoryStub(result: .success(users))
        let sut = UsersViewModel(repository: repository)

        await sut.load()

        #expect(sut.state == .loaded(users))
        #expect(await repository.fetchCount == 1)
    }

    @Test func loadEmptyListShowsEmptyLoadedState() async {
        let sut = UsersViewModel(repository: UsersRepositoryStub(result: .success([])))

        await sut.load()

        #expect(sut.state == .loaded([]))
    }

    @Test func loadFailureShowsGenericMessage() async {
        let sut = UsersViewModel(repository: UsersRepositoryStub(result: .failure(TestError())))

        await sut.load()

        #expect(sut.state == .failed(message: "We couldn't load users. Please try again."))
    }

    @Test func offlineFailureShowsOfflineMessage() async {
        let offline = URLError(.notConnectedToInternet)
        let sut = UsersViewModel(repository: UsersRepositoryStub(result: .failure(offline)))

        await sut.load()

        #expect(sut.state == .failed(message: "You appear to be offline. Check your connection and try again."))
    }

    @Test func showsLoadingWhileRequestIsInFlight() async {
        let repository = UsersRepositoryStub(result: .success(users))
        await repository.holdResponses()
        let sut = UsersViewModel(repository: repository)

        let load = Task { await sut.load() }
        await repository.waitForPendingResponse()

        #expect(sut.isLoading)

        await repository.releasePendingResponses()
        await load.value

        #expect(sut.state == .loaded(users))
    }

    // MARK: - Refresh and retry

    @Test func refreshShowsLoadingThenReplacesUsers() async {
        let repository = UsersRepositoryStub(result: .success(users))
        let sut = UsersViewModel(repository: repository)
        await sut.load()

        let refreshedUsers = [User.fixture(id: 3, name: "Clementine Bauch")]
        await repository.setResult(.success(refreshedUsers))
        await repository.holdResponses()

        let refresh = Task { await sut.load() }
        await repository.waitForPendingResponse()

        #expect(sut.isLoading)

        await repository.releasePendingResponses()
        await refresh.value

        #expect(sut.state == .loaded(refreshedUsers))
        #expect(await repository.fetchCount == 2)
    }

    @Test func retryAfterFailureRecovers() async {
        let repository = UsersRepositoryStub(result: .failure(TestError()))
        let sut = UsersViewModel(repository: repository)
        await sut.load()

        await repository.setResult(.success(users))
        await sut.load()

        #expect(sut.state == .loaded(users))
    }

    @Test func refreshFailureShowsError() async {
        let repository = UsersRepositoryStub(result: .success(users))
        let sut = UsersViewModel(repository: repository)
        await sut.load()

        await repository.setResult(.failure(TestError()))
        await sut.load()

        #expect(sut.state == .failed(message: "We couldn't load users. Please try again."))
    }

    @Test func ignoresLoadWhileAlreadyLoading() async {
        let repository = UsersRepositoryStub(result: .success(users))
        await repository.holdResponses()
        let sut = UsersViewModel(repository: repository)

        let first = Task { await sut.load() }
        await repository.waitForPendingResponse()
        await sut.load()

        await repository.releasePendingResponses()
        await first.value

        #expect(await repository.fetchCount == 1)
        #expect(sut.state == .loaded(users))
    }

    // MARK: - Cancellation

    @Test func cancellationRestoresPreviousStateInsteadOfShowingError() async {
        let repository = UsersRepositoryStub(result: .success(users))
        let sut = UsersViewModel(repository: repository)
        await sut.load()

        await repository.holdResponses()
        let refresh = Task { await sut.load() }
        await repository.waitForPendingResponse()
        refresh.cancel()
        await repository.releasePendingResponses()
        await refresh.value

        #expect(sut.state == .loaded(users))
    }
}

// MARK: - Test doubles

struct TestError: Error {}

extension User {
    static func fixture(
        id: Int = 1,
        name: String = "Leanne Graham",
        email: String = "user@example.com",
        companyName: String = "Example Co"
    ) -> User {
        User(id: id, name: name, email: email, companyName: companyName)
    }
}

/// Repository stub with a configurable result and a way to hold responses,
/// so tests can observe the view model while a request is in flight.
actor UsersRepositoryStub: UsersRepository {
    private var result: Result<[User], any Error>
    private(set) var fetchCount = 0

    private var isHolding = false
    private var heldRequests: [CheckedContinuation<Void, Never>] = []
    private var pendingWaiters: [CheckedContinuation<Void, Never>] = []

    init(result: Result<[User], any Error>) {
        self.result = result
    }

    func setResult(_ result: Result<[User], any Error>) {
        self.result = result
    }

    /// Requests made after this call suspend until `releasePendingResponses()`.
    func holdResponses() {
        isHolding = true
    }

    /// Resumes every held request and stops holding new ones.
    func releasePendingResponses() {
        isHolding = false
        heldRequests.forEach { $0.resume() }
        heldRequests.removeAll()
    }

    /// Suspends until at least one request is being held.
    func waitForPendingResponse() async {
        guard heldRequests.isEmpty else { return }
        await withCheckedContinuation { pendingWaiters.append($0) }
    }

    func fetchUsers() async throws -> [User] {
        fetchCount += 1

        if isHolding {
            await withCheckedContinuation { continuation in
                heldRequests.append(continuation)
                pendingWaiters.forEach { $0.resume() }
                pendingWaiters.removeAll()
            }
        }

        // Behave like URLSession: a cancelled task throws instead of returning data.
        try Task.checkCancellation()
        return try result.get()
    }
}
