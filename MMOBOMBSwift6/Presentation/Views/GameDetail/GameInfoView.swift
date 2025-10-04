//
//  GameInfoView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista que muestra la información principal del juego
/// Incluye estado, género, plataforma, desarrollador, etc.
struct GameInfoView: View {
    
    // MARK: - Properties
    
    let gameDetail: GameDetail
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Badge de estado (Live, Beta, etc)
            StatusBadge(status: gameDetail.status, isLive: gameDetail.isLive)
            
            // Descripción corta
            Text(gameDetail.shortDescription)
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Información organizada en grid
            InfoGrid(gameDetail: gameDetail)
            
            Divider()
            
            // Descripción completa
            VStack(alignment: .leading, spacing: 8) {
                Text("Acerca del juego")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(gameDetail.cleanDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            // Botón para abrir el juego
            Link(destination: URL(string: gameDetail.gameUrl)!) {
                Label("Abrir juego", systemImage: "arrow.up.forward.app.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}

// MARK: - Status Badge

/// Badge que muestra el estado del juego
private struct StatusBadge: View {
    let status: String
    let isLive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isLive ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(status)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            (isLive ? Color.green : Color.orange).opacity(0.15)
        )
        .clipShape(Capsule())
    }
}

// MARK: - Info Grid

/// Grid con la información del juego organizada
private struct InfoGrid: View {
    let gameDetail: GameDetail
    
    var body: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "tag.fill", title: "Género", value: gameDetail.genre)
            InfoRow(icon: "laptopcomputer", title: "Plataforma", value: gameDetail.platform)
            InfoRow(icon: "building.2.fill", title: "Publicador", value: gameDetail.publisher)
            InfoRow(icon: "hammer.fill", title: "Desarrollador", value: gameDetail.developer)
            
            if let releaseDate = gameDetail.releaseDate {
                InfoRow(
                    icon: "calendar",
                    title: "Fecha de lanzamiento",
                    value: formatDate(releaseDate)
                )
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Info Row

/// Fila individual de información
private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
    }
}
