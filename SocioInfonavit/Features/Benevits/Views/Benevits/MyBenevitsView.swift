import SwiftUI

struct MyBenevitsView: View {
    
    // MARK: - Properties
    
    let benevits: [Benevit]
    let strings = BenevitsStrings()
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    // Organizar benevits en páginas de 6 (3 filas x 2 columnas)
    private var pages: [[Benevit]] {
        stride(from: 0, to: benevits.count, by: 6).map {
            Array(benevits[$0..<min($0 + 6, benevits.count)])
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle(strings.myBenevitsNavigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(strings.myBenevitsCloseButton) {
                        dismiss()
                    }
                    .foregroundColor(.primaryRed)
                }
            }
        }
    }
    
    
    @ViewBuilder
    private var contentView: some View {
        if benevits.isEmpty {
            emptyStateView
        } else {
            paginatedView
        }
    }
    
    private var paginatedView: some View {
        VStack(spacing: 0) {
            
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, pageBenevits in
                    BenevitsPageView(benevits: pageBenevits)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if pages.count > 1 {
                pageIndicators
                    .padding(.bottom, 20)
            }
        }
    }
    
    private var pageIndicators: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index
                          ? Color.primaryRed
                          : Color.secondaryGray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
        .padding(.vertical, 12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 70))
                .foregroundColor(.secondaryGray)
            
            VStack(spacing: 12) {
                
                Text(strings.myBenevitsEmptyTitle)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(strings.myBenevitsEmptySubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}


struct BenevitsPageView: View {
    
    let benevits: [Benevit]
    
    // Organizar en filas de 2
    private var rows: [[Benevit]] {
        stride(from: 0, to: benevits.count, by: 2).map {
            Array(benevits[$0..<min($0 + 2, benevits.count)])
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 12) {
                        
                        ForEach(row) { benevit in
                            BenevitCard(benevit: benevit) {
                                // Acción del botón
                            }
                        }
                        
                        // Espacio vacío si solo hay 1 item
                        if row.count == 1 {
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding()
        }
    }
}



#Preview("Paginado") {
    MyBenevitsView(benevits: [
        .mock, .mock, .mock, .mock, .mock, .mock,
        .mock, .mock, .mock, .mock, .mock, .mock
    ])
}

#Preview("Vacío") {
    MyBenevitsView(benevits: [])
}
