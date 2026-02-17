//
//  BenevitCard.swift
//  SocioInfonavit
//
//  Created by luisr on 11/02/26.
//
import SwiftUI

struct BenevitCard: View {
    
    let benevit: Benevit
    let onRequestTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            contentSection
        }
        .frame(height: 320)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            Color.primaryRed
                .frame(height: 60)
            
            if !benevit.isLocked, let ally = benevit.ally {
                VStack {
                    Text(ally.name)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(4)
                }
                .padding(8)
            }
            
            if benevit.isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(8)
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            productImage
            
            Text(benevit.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .frame(height: 36)
            
            if let description = benevit.description {
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondaryGray)
                    .lineLimit(2)
                    .frame(height: 30)
            }
            
            Spacer(minLength: 4)
            
            if benevit.isLocked {
                Button(action: onRequestTap) {
                    Text("Lo quiero")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.primaryRed)
                        .cornerRadius(6)
                }
            } else {
                Color.clear
                    .frame(height: 32)
            }
        }
        .padding(10)
    }
    
    @ViewBuilder
    private var productImage: some View {
        if let imageURL = benevit.imageURL {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .empty:
                    placeholderImage
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.15))
            .frame(height: 80)
            .overlay(
                Image(systemName: benevit.isLocked ? "lock.fill" : "gift.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.primaryRed.opacity(0.3))
            )
    }
}

#Preview {
    HStack(spacing: 12) {
        BenevitCard(benevit: .mock) {
            print("Request tapped")
        }
        
        BenevitCard(benevit: .mockLocked) {
            print("Request tapped")
        }
    }
    .padding()
    .background(Color(.systemGray6))
}
