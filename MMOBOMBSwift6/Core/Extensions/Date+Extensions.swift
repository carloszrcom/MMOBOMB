//
//  Date+Extensions.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 3/10/25.
//

import Foundation

extension Date {
    
    /// Formatea la fecha en formato legible en español
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
    
    /// Indica si la fecha es de hoy
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
