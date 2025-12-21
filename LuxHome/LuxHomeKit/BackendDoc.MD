+# Booster-Style Architecture Overview for wavelength-ios-client
     2 +
     3 +This document explains how to organize the app like Booster does: a single shared model that owns data and netwo
        rking, views that observe that model, and consistent request setup using UnionNetworking.
     4 +
     5 +## Core Idea
     6 +
     7 +Have **one brain** (a shared model) that:
     8 +- Knows the user/session (token, userId, userName).
     9 +- Exposes methods for all network actions (search, fetch albums, fetch details, submit review).
    10 +- Stores shared state (albums, search results, loading/error flags, toasts).
    11 +- Uses UnionNetworking uniformly (method, JSON headers, addToken).
    12 +
    13 +Views do **not** build requests; they call the model’s methods and bind to its published state.
    14 +
    15 +## Model Setup
    16 +
    17 +- Keep `WavelengthModel` as the single shared instance.
    18 +- Inject it once at the root (App/ContentView) via `.environment(model)` or `.environmentObject` (if you switch
        to `ObservableObject`).
    19 +- Expose model state:
    20 +  - `userId`, `userName`, `isLoggedIn`
    21 +  - `albums`, `searchResults`
    22 +  - `isLoading`, `errorMessage`, `showReviewSavedToast`
    23 +- Expose methods that wrap UnionNetworking:
    24 +  - `fetchUserAlbums()`
    25 +  - `searchAlbums(query:)`
    26 +  - `fetchMusicDetails(albumId:)`
    27 +  - `fetchMusicDetailsAndReviews(albumId:)`
    28 +  - `submitReview(albumId:rating:reviewText:)`
    29 +- Centralize auth:
    30 +  - `setupAuth(bearerToken:userId:userName:)` sets Keychain/user defaults once.
    31 +  - All network methods call `addToken()` internally as needed.
    32 +
    33 +## View Consumption Pattern
    34 +
    35 +- Inject the model: `@Environment(WavelengthModel.self) var model`.
    36 +- Bind UI to model state:
    37 +  - Use `model.albums`, `model.isLoading`, `model.errorMessage` instead of local `@State`.
    38 +  - Use `model.searchResults` if you move search results into the model.
    39 +- Call model methods instead of services:
    40 +  - `await model.searchAlbums(query: ...)`
    41 +  - `await model.fetchUserAlbums()`
    42 +  - `await model.submitReview(...)`
    43 +- Pass the model through sheets/child views via `.environment(model)` so they reuse the same brain.
    44 +
    45 +## Networking Consistency (UnionNetworking)
    46 +
    47 +- Inside model methods, always:
    48 +  - Build request with `Networking.request(endpoint: ..., params: ...)`.
    49 +  - Set `httpMethod` explicitly.
    50 +  - Call `setJSON()` when sending/expecting JSON.
    51 +  - Call `addToken()` for authenticated endpoints.
    52 +  - Use `get()` for Decodable responses, `execute()` for raw data.
    53 +- Do not build requests in views.
    54 +
    55 +## Error Handling
    56 +
    57 +- Catch errors in model methods; map to `errorMessage` or throw back for the UI to display.
    58 +- Avoid `print` or silent catches in views; keep logging/handling in the model.
    59 +
    60 +## Navigation/Data Flow
    61 +
    62 +- When moving between screens (e.g., Search → Review), pass existing data via the model or bindings to avoid ref
        etching if you already have it.
    63 +- Cache reusable data in the model (e.g., music details) if you want to skip redundant calls.
    64 +
    65 +## Cleanup Checklist
    66 +
    67 +- Remove direct `WavelengthModel.shared` uses in views; rely on injected model.
    68 +- Remove direct service/API calls in views; wrap them in model methods.
    69 +- Move Keychain/userId/userName setup into the model; expose login state.
    70 +- Standardize request setup in model/service methods only.
    71 +- Use model state instead of duplicating `@State` for shared data/loading/errors.
    72 +
    73 +## Minimal Migration Steps
    74 +
    75 +1) Inject `WavelengthModel.shared` at the app root and use `@Environment(WavelengthModel.self)` in views.
    76 +2) Replace service/API calls in views with model method calls (one flow at a time).
    77 +3) Move auth/session setup into the model (`setupAuth`), remove Keychain touches from views.
    78 +4) Use model state for albums/loading/error/search results; remove duplicates in views.
    79 +5) Ensure all network requests go through model/service methods with consistent UnionNetworking setup.
