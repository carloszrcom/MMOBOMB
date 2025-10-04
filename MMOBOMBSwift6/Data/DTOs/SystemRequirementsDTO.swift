//
//  SystemRequirementsDTO.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

/// DTO para los requisitos mínimos del sistema
/// Algunos juegos no tienen requisitos (juegos web), por eso es opcional
struct SystemRequirementsDTO: Codable {
    let os: String?
    let processor: String?
    let memory: String?
    let graphics: String?
    let storage: String?
}
