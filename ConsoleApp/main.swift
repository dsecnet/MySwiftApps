//
//  main.swift
//  ConsoleApp
//
//  Created by Vusal Dadashov on 22.01.26.
//

// main.swift
//Model
// Modelin icinde student ve grade swift olacaq  fayli olacaq
//UI folderi
//- Menu UI in icinde
//Services Folder  - studentservis .swift

// Utilities
//- InputReader



import Foundation


var isRunning = true
//print(Grade.A.definition)






while isRunning {
    showMenu()
    print("Seçim edin: ")
    let choice = readInput()
    
    switch choice {
        case "1":
            registerStudent()
        case "2":
            showStudentInfo()
        case "3":
            isRunning = false
        default:
            print("❌ Seçim Səhvdir . Yenidən cəhd edin")
        
    }
}

