//
//  SystemRequirements.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// Modelo para los requisitos mínimos del sistema
struct SystemRequirements: Hashable {
    let os: String
    let processor: String
    let memory: String
    let graphics: String
    let storage: String
    
    // MARK: - Computed Properties
    
    /// Convierte los requisitos en un array de tuplas para mostrar en lista
    var allRequirements: [(title: String, value: String)] {
        [
            ("Sistema Operativo", os),
            ("Procesador", processor),
            ("Memoria RAM", memory),
            ("Tarjeta Gráfica", graphics),
            ("Almacenamiento", storage)
        ]
    }
}
