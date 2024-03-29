//
//  DirectionConverter.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/25/24.
//

func convertDegreesToDirection(degrees: Int) -> String {
    let allDirections = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
    let index = Int((Double(degrees) / 45.0).rounded()) % allDirections.count
    return allDirections[index]
}
