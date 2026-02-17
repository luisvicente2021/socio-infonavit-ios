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
    
    // MARK: - Load Benevits Tests
    
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
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 segundos
        
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
    
    // MARK: - Search Tests
    
    func test_searchBenevits_withQuery_filtersResults() async {
        // Given
        let benevits = [
            Benevit(id: 1, name: "Cafe Starbucks", description: "Descuento", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false),
            Benevit(id: 2, name: "Pizza Dominos", description: "2x1", vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        mockNetwork.mockSearchResponse = SearchResponse(benevits: benevits)
        
        // When
        viewModel.searchBenevits(query: "Cafe")
        
        // CRÍTICO: Esperar el debounce (500ms) + tiempo de ejecución
        try? await Task.sleep(nanoseconds: 700_000_000) // 0.7 segundos
        
        // Then
        XCTAssertTrue(mockNetwork.requestCalled, "Debe haber hecho el request")
        XCTAssertEqual(viewModel.allBenevits.count, 2, "Debe tener 2 benevits del search")
        XCTAssertFalse(viewModel.isSearching, "No debe estar buscando")
    }
    
    func test_searchBenevits_withEmptyQuery_loadsAll() async {
        // Given
        let locked = [
            Benevit(id: 1, name: "Locked", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: true)
        ]
        let unlocked = [
            Benevit(id: 2, name: "Unlocked", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        ]
        mockNetwork.mockBenevitsResponse = BenevitsResponse(locked: locked, unlocked: unlocked)
        
        // When
        viewModel.searchBenevits(query: "")
        
        // Wait for debounce + execution
        try? await Task.sleep(nanoseconds: 700_000_000)
        
        // Then
        XCTAssertEqual(viewModel.allBenevits.count, 2, "Debe cargar todos los benevits")
    }
    
    func test_searchBenevits_debounce_cancelsOldSearches() async {
        // Given
        mockNetwork.mockSearchResponse = SearchResponse(benevits: [])
        
        // When - Llamar múltiples veces rápido
        viewModel.searchBenevits(query: "a")
        viewModel.searchBenevits(query: "ab")
        viewModel.searchBenevits(query: "abc")
        
        // Wait for debounce
        try? await Task.sleep(nanoseconds: 700_000_000)
        
        // Then - Solo debe haber hecho 1 request (el último)
        XCTAssertEqual(mockNetwork.requestCallCount, 1, "Debe cancelar búsquedas anteriores")
    }
    
    // MARK: - Display Tests
    
    func test_displayedBenevits_withEmptyQuery_showsAll() async {
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
    
    func test_displayedBenevits_withQuery_filters() async {
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
    
    // MARK: - Loading State Tests
    
    func test_loadBenevits_setsLoadingState() async {
        // Given
        mockNetwork.mockDelay = 0.2
        
        // When
        viewModel.loadBenevits()
        
        // Then - Inmediatamente
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        XCTAssertTrue(viewModel.isLoading, "Debe estar loading")
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 250_000_000) // 0.25s más
        XCTAssertFalse(viewModel.isLoading, "No debe estar loading")
    }
    
    // MARK: - Error Handling Tests
    
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
    
    // MARK: - Request Benevit Test
    
    func test_requestBenevit_doesNotCrash() {
        // Given
        let benevit = Benevit(id: 1, name: "Test", description: nil, vectorFullPath: nil, ally: nil, category: nil, expirationDate: nil, isLocked: false)
        
        // When & Then
        XCTAssertNoThrow(viewModel.requestBenevit(benevit))
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_isCorrect() {
        // Then
        XCTAssertTrue(viewModel.allBenevits.isEmpty)
        XCTAssertTrue(viewModel.myBenevits.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.searchQuery.isEmpty)
    }
}














