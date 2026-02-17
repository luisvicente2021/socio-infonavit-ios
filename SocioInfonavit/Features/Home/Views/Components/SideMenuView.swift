import SwiftUI

struct SideMenuView: View {
    
    @Binding var isShowing: Bool
    let onMyBenevits: () -> Void
    let onLogout: () -> Void
    let strings: HomeStrings
    
    var body: some View {
        ZStack(alignment: .leading) {
            if isShowing {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeMenu()
                    }
            }
            
            if isShowing {
                menuContent
                    .transition(.move(edge: .leading))
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                if value.translation.width < -50 {
                                    closeMenu()
                                }
                            }
                    )
            }
        }
    }
    
    private func closeMenu() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isShowing = false
        }
    }
    
    private var menuContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuHeader
            
            ScrollView {
                VStack(spacing: 0) {
                    MenuSectionHeader(title: strings.menuSectionPrincipal)
                    
                    MenuItemButton(
                        icon: "house.fill",
                        title: strings.menuItemInicio,
                        badge: nil
                    ) {
                        closeMenu()
                    }
                    
                    MenuItemButton(
                        icon: "heart.fill",
                        title: strings.menuItemMisBenevits,
                        badge: "12"
                    ) {
                        closeMenu()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onMyBenevits()
                        }
                    }
                    
                    MenuItemButton(
                        icon: "magnifyingglass",
                        title: strings.menuItemBuscar,
                        badge: nil
                    ) {
                        closeMenu()
                    }
                    
                    MenuSectionHeader(title: strings.menuSectionCuenta)
                    
                    MenuItemButton(
                        icon: "person.fill",
                        title: strings.menuItemPerfil,
                        badge: nil
                    ) {
                        closeMenu()
                    }
                    
                    MenuItemButton(
                        icon: "bell.fill",
                        title: strings.menuItemNotificaciones,
                        badge: "3"
                    ) {
                        closeMenu()
                    }
                    
                    MenuItemButton(
                        icon: "gearshape.fill",
                        title: strings.menuItemConfiguracion,
                        badge: nil
                    ) {
                        closeMenu()
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                    
                    MenuItemButton(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: strings.menuItemCerrarSesion,
                        badge: nil,
                        isDestructive: true
                    ) {
                        closeMenu()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onLogout()
                        }
                    }
                    
                    Spacer(minLength: 40)
                    
                    menuFooter
                }
            }
        }
        .frame(width: 300)
        .background(Color.primaryRed)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 0)
    }
    
    private var menuHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                Spacer()
                
                Button {
                    closeMenu()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(strings.menuHeaderWelcome)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                
                Text(strings.menuHeaderUserLabel)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color.primaryRed,
                    Color.primaryRed.opacity(0.8),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var menuFooter: some View {
        VStack(spacing: 8) {
            Text(strings.menuFooterTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            Text(strings.menuFooterVersion)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
}

struct MenuSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)
    }
}


struct MenuItemButton: View {
    let icon: String
    let title: String
    let badge: String?
    var isDestructive: Bool = false
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primaryRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                isPressed ? Color.white.opacity(0.15) : Color.clear
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        SideMenuView(
            isShowing: .constant(true),
            onMyBenevits: { print("My Benevits") },
            onLogout: { print("Logout") },
            strings: HomeStrings()
        )
    }
}
