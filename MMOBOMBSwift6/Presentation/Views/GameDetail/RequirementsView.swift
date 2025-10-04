//
//  RequirementsView.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import SwiftUI

/// Vista que muestra los requisitos mínimos del sistema
struct RequirementsView: View {
    
    // MARK: - Properties
    
    let requirements: SystemRequirements
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Título de la sección
            HStack {
                Image(systemName: "desktopcomputer")
                    .foregroundStyle(.blue)
                
                Text("Requisitos mínimos del sistema")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            // Lista de requisitos
            VStack(spacing: 12) {
                ForEach(requirements.allRequirements, id: \.title) { requirement in
                    RequirementRow(
                        title: requirement.title,
                        value: requirement.value
                    )
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

// MARK: - Requirement Row

/// Fila individual de un requisito
private struct RequirementRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
