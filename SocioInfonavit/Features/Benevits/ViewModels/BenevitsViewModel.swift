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
    
    // MARK: - isSearching indica el debounce activo (delay visual mientras el usuario escribe)
    // Cuando el endpoint esté disponible, también cubrirá la espera de la respuesta del API.
    @Published var isSearching: Bool = false
    
    private var searchTask: Task<Void, Never>?
    
    init(networkManager: NetworkServiceProtocol = NetworkConfiguration.createService()) {
        self.networkManager = networkManager
    }
    
    // MARK: - Computed: filtra localmente sobre allBenevits
    // Cuando el endpoint de búsqueda esté activo, este computed simplemente
    // devolverá allBenevits sin filtrar (el servidor ya habrá devuelto los resultados correctos).
    var displayedBenevits: [Benevit] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            return allBenevits
        }
        
        return allBenevits.filter { benevit in
            benevit.name.localizedCaseInsensitiveContains(trimmed) ||
            (benevit.description?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }
    
    func loadBenevits() {
        Task { await performLoadBenevits() }
    }
    
    func searchBenevits(query: String) {
        searchTask?.cancel()
        
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            isSearching = false
            return
        }
        
        isSearching = true
        
        searchTask = Task {
            // Debounce: espera a que el usuario deje de escribir
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            // TODO: Descomentar cuando el endpoint esté disponible.
            // En ese caso también eliminar el filtro local en displayedBenevits
            // y simplemente retornar allBenevits allí.
            // await performSearch(query: trimmed)
            
            // Con mock, el filtro ya ocurre en displayedBenevits de forma reactiva.
            // Solo apagamos el indicador de búsqueda tras el debounce.
            isSearching = false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func retry() {
        loadBenevits()
    }
    
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
    
    // TODO: Activar cuando el endpoint de búsqueda esté disponible.
    // Reemplaza el filtro local de displayedBenevits por resultados del servidor.
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
            
            // El servidor devuelve los resultados filtrados, allBenevits se reemplaza
            // y displayedBenevits lo retornará sin filtrar (query ya no es vacía).
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
