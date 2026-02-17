//
//  BenevitsViewModel.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//

import Foundation

@MainActor
final class BenevitsViewModel: ObservableObject {
    
    private let networkManager: NetworkServiceProtocol
    private let strings = BenevitsStrings()
    
    @Published var allBenevits: [Benevit] = []
    @Published var myBenevits: [Benevit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    
    private var searchTask: Task<Void, Never>?
    
    init(networkManager: NetworkServiceProtocol = NetworkConfiguration.createService()) {
        self.networkManager = networkManager
    }
    
    var displayedBenevits: [Benevit] {
        if searchQuery.isEmpty {
            return allBenevits
        }
        
        return allBenevits.filter { benevit in
            benevit.name.localizedCaseInsensitiveContains(searchQuery) ||
            (benevit.description?.localizedCaseInsensitiveContains(searchQuery) ?? false)
        }
    }
    
    func loadBenevits() {
        Task { await performLoadBenevits() }
    }
    
    func searchBenevits(query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            if !Task.isCancelled {
                if query.isEmpty {
                    await performLoadBenevits()
                } else {
                    await performSearch(query: query)
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func retry() {
        loadBenevits()
    }
    
    /// Limpia todos los datos al hacer logout
    func clearData() {
        allBenevits = []
        myBenevits = []
        searchQuery = ""
        errorMessage = nil
        isLoading = false
        isSearching = false
        searchTask?.cancel()
        searchTask = nil
    }
    
    func requestBenevit(_ benevit: Benevit) {
        print("💝 \(strings.requestSuccessMessage): \(benevit.name)")
    }
    
    private func performLoadBenevits() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = SocioInfonavitEndpoint.landingBenevits
            let response = try await networkManager.request(
                endpoint: endpoint,
                responseType: BenevitsResponse.self
            )
            
            let locked = response.locked.map { $0.withLockState(true) }
            let unlocked = response.unlocked.map { $0.withLockState(false) }
            
            allBenevits = shuffleBenevits(locked: locked, unlocked: unlocked)
            myBenevits = unlocked
            
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            errorMessage = String(
                format: strings.unexpectedErrorFormat,
                error.localizedDescription
            )
        }
        
        isLoading = false
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        
        do {
            let endpoint = SocioInfonavitEndpoint.searchBenevits(query: query)
            let response = try await networkManager.request(
                endpoint: endpoint,
                responseType: SearchResponse.self
            )
            
            allBenevits = response.benevits
            
        } catch let error as NetworkError {
            handleError(error)
        } catch {
            errorMessage = String(
                format: strings.unexpectedErrorFormat,
                error.localizedDescription
            )
        }
        
        isSearching = false
    }
    
    private func shuffleBenevits(locked: [Benevit], unlocked: [Benevit]) -> [Benevit] {
        var result: [Benevit] = []
        let maxCount = max(locked.count, unlocked.count)
        
        for i in 0..<maxCount {
            if i < unlocked.count { result.append(unlocked[i]) }
            if i < locked.count { result.append(locked[i]) }
        }
        
        return result
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .unauthorized:
            errorMessage = strings.sessionExpiredError
            
        case .noInternetConnection:
            errorMessage = strings.noInternetError
            
        case .timeout:
            errorMessage = strings.timeoutError
            
        default:
            errorMessage = error.localizedDescription
        }
    }
}
