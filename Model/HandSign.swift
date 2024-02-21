//
//  File.swift
//  
//
//  Created by Darren Thiores on 19/02/24.
//

import Foundation
import SwiftUI

enum HandSign: String {
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case H = "H"
    case I = "I"
    case J = "J"
    case K = "K"
    case L = "L"
    case M = "M"
    case N = "N"
    case O = "O"
    case P = "P"
    case Q = "Q"
    case R = "R"
    case S = "S"
    case T = "T"
    case U = "U"
    case V = "V"
    case W = "W"
    case X = "X"
    case Y = "Y"
    case Z = "Z"
    case Space = "Space"
    case Delete = "Delete"
    
    static let allValues = [A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, Space, Delete]
}

extension HandSign {
    func getImage() -> UIImage? {
        return UIImage(named: self.rawValue)
    }
}
