//
//  Domain.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/25/24.
//

struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let name: String
}

struct ForecastResponse: Codable {
    let list: [WeatherForecast]
}

struct WeatherForecast: Codable {
    let dt: Int
    let main: Main
    let weather: [Weather]
    let dt_txt: String
}

struct Weather: Codable {
    let icon: String
    let main: String
    let description: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
    let pressure: Int
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Clouds: Codable {
    let all: Int
}
