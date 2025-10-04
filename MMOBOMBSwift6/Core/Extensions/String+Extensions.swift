//
//  String+Extensions.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

extension String {
    
    /// Remueve espacios en blanco al inicio y final
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Indica si el string está vacío después de remover espacios
    var isBlank: Bool {
        self.trimmed.isEmpty
    }
}
