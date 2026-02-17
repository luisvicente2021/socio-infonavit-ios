import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var viewModel: BenevitsViewModel
    @State private var showMyBenevits = false
    @State private var showLogoutAlert = false
    @State private var showSideMenu = false
    
    private let strings = HomeStrings()
    
    var onLogout: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                contentView
                
                SideMenuView(
                    isShowing: $showSideMenu,
                    onMyBenevits: {
                        showMyBenevits = true
                    },
                    onLogout: {
                        showLogoutAlert = true
                    },
                    strings: strings
                )
            }
            .navigationTitle(strings.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSideMenu.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 20))
                            .foregroundColor(.primaryRed)
                    }
                    .accessibilityLabel(strings.menuItemInicio)
                }
            }
            .sheet(isPresented: $showMyBenevits) {
                MyBenevitsView(benevits: viewModel.myBenevits)
            }
            .alert(strings.logoutAlertTitle, isPresented: $showLogoutAlert) {
                Button(strings.logoutCancelButton, role: .cancel) {}
                Button(strings.logoutConfirmButton, role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text(strings.logoutAlertMessage)
            }
            .onAppear {
                if viewModel.allBenevits.isEmpty {
                    viewModel.loadBenevits()
                }
            }
        }
    }
    
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.allBenevits.isEmpty {
            ScrollView {
                SkeletonView()
                    .padding()
            }
        } else if let errorMessage = viewModel.errorMessage,
                  viewModel.allBenevits.isEmpty {
            errorView(message: errorMessage)
        } else {
            benevitsList
        }
    }
    
    private var benevitsList: some View {
        VStack(spacing: 0) {
            SearchBar(text: $viewModel.searchQuery) { query in
                viewModel.searchBenevits(query: query)
            }
            .padding()
            
            ScrollView {
                if viewModel.isSearching {
                    SkeletonView()
                        .padding()
                } else if viewModel.displayedBenevits.isEmpty {
                    emptyStateView
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 16
                    ) {
                        ForEach(viewModel.displayedBenevits) { benevit in
                            BenevitCard(benevit: benevit) {
                                viewModel.requestBenevit(benevit)
                            }
                        }
                    }
                    .padding()
                }
            }
            .refreshable {
                viewModel.loadBenevits()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondaryGray)
            
            Text(strings.emptySearchTitle)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Text(strings.emptySearchMessage)
                .font(.system(size: 16))
                .foregroundColor(.secondaryGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top, 60)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.primaryRed)
            
            VStack(spacing: 12) {
                Text(strings.genericErrorTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            PrimaryButton(strings.retryButton) {
                viewModel.retry()
            }
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func handleLogout() {
        UserSessionManager.shared.logout()
        onLogout()
    }
}

#Preview {
    HomeView {
        print("Logout")
    }
}
