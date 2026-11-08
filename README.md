User List App
A SwiftUI app that lists users from JSONPlaceholder, with loading, error, empty and refresh states.

Architecture
MVVM with a repository and a small networking layer, wired together in UserApp (the composition root):
UsersListView → UsersViewModel → UsersRepository → HTTPClient → URLSession
                (@Observable)    (DTO → domain)    (status + decoding)
UserApp/Networking: Endpoint, NetworkError, HTTPClient / URLSessionHTTPClient
UserApp/Users: UserDTO, User, UsersRepository, UsersViewModel, UsersListView

Notes

Bugs: the client decoded { "users": [...] }, but the API returns a top-level array, so every load failed. User wasn't Identifiable, so List(users) didn't compile. The view model was held in @ObservedObject, so it was recreated when the view rebuilt and lost its state.

Fixes: decode [UserDTO] and map to a domain User; validate the HTTP status before decoding; own an @MainActor @Observable view model with @State.

Refresh: reuses load(), shows the loading state, and disables the button while a request is in flight. Repeat calls are ignored, and a cancelled request restores the previous state instead of showing an error.

Testing: each layer sits behind a protocol and is injected. The view model is tested with a stub repository that can hold responses, covering success, empty, error messages, refresh, retry, ignored repeat loads and cancellation. Nothing hits the real network.

Trade-offs: the repository and DTO layers are more structure than one screen strictly needs, but they keep the API shape out of the UI and make new endpoints cheap to add. Refresh replaces the list with a loading view, as the brief asks; keeping the list visible with an inline spinner would be gentler UX. No caching or retry policy yet.
