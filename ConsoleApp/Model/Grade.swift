//
//  Grade.swift
//  ConsoleApp
//
//  Created by Vusal Dadashov on 22.01.26.
//



enum Grade: String {
    case A
    case B
    case C
    case D
    case F
    
    var definition : String {
        switch self {
        case .A: return "Çox Əla"
        case .B: return "Əla"
        case .C: return "Yaxşı"
        case .D: return "Pis"
        case .F: return "Kəsilib"
        
        }
    }
    
    var examPassed : Bool {
        switch self {
        case .A, .B, .C:
            return true
        case .D, .F:
            return false
        }
    }
}
