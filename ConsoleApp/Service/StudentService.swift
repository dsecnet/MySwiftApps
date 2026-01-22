//
//  StudentService.swift
//  ConsoleApp
//
//  Created by Vusal Dadashov on 22.01.26.
//

var students : [Int : Student] = [:]

func registerStudent(){
    print("Tələbə  ID-i daxil edin")
    let idString = readInput()
    guard let id = Int(idString)  else {
        print("Səhv İD seçilib ")
        return
    }
    
    if students[id] != nil {
        print("Bu id \(id) li tələbə artıq var. Yeni İD cəhd edin. ")
        return
    }
    print("Tələbə adını daxil edin")
    let name = readInput()
    
    print("Tələbənin yaşını daxil edin")
    guard let age = Int(readInput()), age > 0 else {
        print("Yanlış rəqəm daxil edildi . Yenidən cəhd edinş ")
        return
    }
    
    print("Tələbənin Grade -ni daxil edin :  A, B, C, D , F ")
    guard let gradeInput =  Grade(rawValue: readInput().uppercased()) else {
        print("Yanlı. Grade . Yenidən cəhd edin")
        return
    }
    let student = Student(id: id, name: name, age: age, grade: gradeInput)
    students[id] = student
    print("✅ Tələbə Qeydiyyati tamamlandı")
}

func showStudentInfo() {
    print("Tələbə İD daxil edin ")
    
    guard let id = Int(readInput()) else {
        print("Yanlış İD  ")
        return
    }
    guard let student = students[id] else {
        print("Yanlış tələbə İD \(id) i ")
        return
    }
    print(student.info)
 }
