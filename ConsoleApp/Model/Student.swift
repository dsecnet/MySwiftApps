//
//  Student.swift
//  ConsoleApp
//
//  Created by Vusal Dadashov on 22.01.26.
//



struct Student {
    let id : Int
    let name : String
    let age : Int
    let grade: Grade
    var info : String {
        """
        ---
        Student ID : \(id)
        Name : \(name)
        Age : \(age)
        Grade: \(grade.rawValue) \(grade.definition)
        Status: \(passingStatus)
        ---
        """
        
    }
    private var passingStatus : String {
        grade.examPassed ?  "✅Ugurlu" : "❌Uğursuz"
}


}
