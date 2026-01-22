//
//  InputReader.swift
//  ConsoleApp
//
//  Created by Vusal Dadashov on 22.01.26.
//

import Foundation

func readInput() ->  String {
    readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}
