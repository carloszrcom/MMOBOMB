//
//  AppIcons.swift
//  MMOBOMBSwift6
//
//  Created by CarlosZR on 22/10/25.
//

import SwiftUI

/// Icons manager.
enum AppIcons: String {
    case homeFill = "house.fill"
    case lightbulbFill = "lightbulb.fill"
    case arrowRightCircleFill = "arrow.right.circle.fill"
    case personFill = "person.fill"
    case gearShape = "gearshape"
    
    var name: String {
        return self.rawValue
    }
    
    var image: Image {
        return Image(systemName: self.rawValue)
    }
}
