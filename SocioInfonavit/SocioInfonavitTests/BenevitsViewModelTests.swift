//
//  BenevitsViewModelTests.swift
//  SocioInfonavit
//
//  Created by luisr on 14/02/26.
//

import XCTest
@testable import SocioInfonavit

@MainActor
final class BenevitsViewModelTests: XCTestCase {
    
    var viewModel: BenevitsViewModel!
    var mockNetwork: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetwork = MockNetworkService()
        viewModel = BenevitsViewModel(networkManager: mockNetwork)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetwork.reset()
        mockNetwork = nil
        super.tearDown()
    }
    
    func test_loadBenevits_success() async {
        // Given
        let locked = [
            Benevit(id: 1, name: "Locked 1", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: true)
        ]
        let unlocked = [
            Benevit(id: 2, name: "Unlocked 1", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 3, name: "Unlocked 2", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        mockNetwork.mockBenevitsResponse = BenevitsResponse(locked: locked, unlocked: unlocked)
        
        // When
        viewModel.loadBenevits()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading, "Loading debe ser false")
        XCTAssertEqual(viewModel.allBenevits.count, 3, "Debe tener 3 benevits (1 locked + 2 unlocked)")
        XCTAssertEqual(viewModel.myBenevits.count, 2, "Mis benevits debe tener solo los unlocked")
        XCTAssertNil(viewModel.errorMessage, "No debe haber error")
        XCTAssertTrue(mockNetwork.requestCalled, "Debe haber hecho request")
    }
    
    func test_loadBenevits_failure() async {
        // Given
        mockNetwork.shouldSucceed = false
        mockNetwork.mockError = .noInternetConnection
        
        // When
        viewModel.loadBenevits()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.allBenevits.isEmpty, "No debe tener benevits")
        XCTAssertNotNil(viewModel.errorMessage, "Debe haber mensaje de error")
        XCTAssertEqual(viewModel.errorMessage, "No hay conexión a internet")
    }
    
    func test_loadBenevits_setsLoadingState() async {
        // Given
        mockNetwork.mockDelay = 0.2
        
        // When
        viewModel.loadBenevits()
        
        // Then
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s — en medio de la carga
        XCTAssertTrue(viewModel.isLoading, "Debe estar loading mientras espera respuesta")
        try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s más — ya terminó
        XCTAssertFalse(viewModel.isLoading, "No debe estar loading al terminar")
    }
    
    func test_searchBenevits_withQuery_setsIsSearchingThenFalse() async {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Cafe Starbucks", description: "Descuento", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Pizza Dominos", description: "2x1", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        
        // When
        viewModel.searchBenevits(query: "Cafe")
        
        // Then
        XCTAssertTrue(viewModel.isSearching, "Debe estar buscando durante el debounce")
        try? await Task.sleep(nanoseconds: 700_000_000) // esperar debounce (500ms) + margen
        XCTAssertFalse(viewModel.isSearching, "No debe estar buscando al terminar el debounce")
        XCTAssertFalse(mockNetwork.requestCalled, "No debe llamar al API con el filtro local activo")
    }
    
    func test_searchBenevits_withQuery_filtersResultsLocally() async {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Cafe Starbucks", description: "Descuento", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Pizza Dominos", description: "2x1", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        
        // When
        viewModel.searchQuery = "Cafe"
        
        // Then
        let displayed = viewModel.displayedBenevits
        XCTAssertEqual(displayed.count, 1, "Debe mostrar solo el benevit que contiene 'Cafe'")
        XCTAssertEqual(displayed.first?.name, "Cafe Starbucks")
        XCTAssertEqual(viewModel.allBenevits.count, 2, "allBenevits no debe cambiar con el filtro local")
    }
    
    func test_searchBenevits_withEmptyQuery_showsAllBenevits() async {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Locked", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: true),
            Benevit(id: 2, name: "Unlocked", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        viewModel.searchQuery = ""
        
        // When
        viewModel.searchBenevits(query: "")
        
        // Then
        XCTAssertFalse(viewModel.isSearching, "Query vacía no debe activar isSearching")
        XCTAssertEqual(viewModel.displayedBenevits.count, 2, "Debe mostrar todos los benevits")
        XCTAssertFalse(mockNetwork.requestCalled, "No debe llamar al API")
    }
    
    func test_searchBenevits_debounce_cancelsOldSearches() async {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "abc test", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        
        // When — simula escritura rápida
        viewModel.searchBenevits(query: "a")
        viewModel.searchBenevits(query: "ab")
        viewModel.searchBenevits(query: "abc")
        
        // Then
        XCTAssertTrue(viewModel.isSearching, "Debe estar en debounce tras la última búsqueda")
        try? await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertFalse(viewModel.isSearching, "Debe haber terminado el debounce")
        XCTAssertEqual(mockNetwork.requestCallCount, 0, "No debe haber llamado al API con filtro local activo")
        viewModel.searchQuery = "abc"
        XCTAssertEqual(viewModel.displayedBenevits.count, 1, "Debe filtrar con la query final")
    }
    
    func test_displayedBenevits_withEmptyQuery_showsAll() {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Test 1", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Test 2", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        viewModel.searchQuery = ""
        
        // When
        let displayed = viewModel.displayedBenevits
        
        // Then
        XCTAssertEqual(displayed.count, 2, "Debe mostrar todos")
    }
    
    func test_displayedBenevits_withQuery_filters() {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Cafe Starbucks", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Pizza Dominos", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 3, name: "Cafe Local", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        viewModel.searchQuery = "Cafe"
        
        // When
        let displayed = viewModel.displayedBenevits
        
        // Then
        XCTAssertEqual(displayed.count, 2, "Debe filtrar y mostrar solo los que contienen 'Cafe'")
        XCTAssertTrue(displayed.allSatisfy { $0.name.contains("Cafe") })
    }
    
    func test_displayedBenevits_matchesByDescription() {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Beneficio A", description: "Descuento en cine", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Beneficio B", description: "2x1 en pizza", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        viewModel.searchQuery = "cine"
        
        // When
        let displayed = viewModel.displayedBenevits
        
        // Then
        XCTAssertEqual(displayed.count, 1, "Debe encontrar benevits que coincidan por descripción")
        XCTAssertEqual(displayed.first?.id, 1)
    }
    
    func test_displayedBenevits_withWhitespaceOnlyQuery_showsAll() {
        // Given
        viewModel.allBenevits = [
            Benevit(id: 1, name: "Test", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        viewModel.searchQuery = "   "
        
        // When
        let displayed = viewModel.displayedBenevits
        
        // Then
        XCTAssertEqual(displayed.count, 1, "Espacios solos deben tratarse como query vacía")
    }
    
    func test_clearError_removesErrorMessage() {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_retry_reloadsBenevits() async {
        // Given
        mockNetwork.mockBenevitsResponse = BenevitsResponse(locked: [], unlocked: [
            Benevit(id: 1, name: "Test", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ])
        
        // When
        viewModel.retry()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertEqual(viewModel.allBenevits.count, 1)
        XCTAssertTrue(mockNetwork.requestCalled)
    }
    
    func test_handleError_unauthorized() async {
        // Given
        mockNetwork.shouldSucceed = false
        mockNetwork.mockError = .unauthorized
        
        // When
        viewModel.loadBenevits()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Sesión expirada. Por favor inicia sesión nuevamente")
    }
    
    func test_handleError_timeout() async {
        // Given
        mockNetwork.shouldSucceed = false
        mockNetwork.mockError = .timeout
        
        // When
        viewModel.loadBenevits()
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "La solicitud tardó demasiado tiempo")
    }
    
    func test_requestBenevit_doesNotCrash() {
        // Given
        let benevit = Benevit(id: 1, name: "Test", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        
        // When & Then
        XCTAssertNoThrow(viewModel.requestBenevit(benevit))
    }
    
    func test_initialState_isCorrect() {
        XCTAssertTrue(viewModel.allBenevits.isEmpty)
        XCTAssertTrue(viewModel.myBenevits.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.searchQuery.isEmpty)
    }
}
