//
//  TodayWeatherAPI.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/25/24.
//

import UIKit

func fetchWeatherData(latitude: Double, longitude: Double, presenter: UIViewController?, completion: @escaping (WeatherData?) -> Void) {
    let API_KEY: String = "25bb477f7d5ee66caf6fa7def55d7ed7"
    let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)"
    
    URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
        guard let data = data, error == nil else {
            showError(message: "Error fetching weather data", presenter: presenter)
            completion(nil)
            return
        }
        
        do {
            let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
            completion(weatherData)
        } catch {
            print("Error decoding weather data: \(error.localizedDescription)")
            showError(message: "Error decoding weather data", presenter: presenter)
            completion(nil)
        }
    }.resume()
}
