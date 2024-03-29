//
//  ForecastWeatherAPI.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/26/24.
//

import UIKit

func fetchForecastData(latitude: Double, longitude: Double, presenter: UIViewController?, completion: @escaping (ForecastResponse?) -> Void) {
    let API_KEY: String = "25bb477f7d5ee66caf6fa7def55d7ed7"
    let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(API_KEY)"
    
    URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
        
        guard let data = data, error == nil else {
            showError(message: "Error fetching forecast data", presenter: presenter)
            return
        }
        
        do {
            let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
            completion(forecastResponse)
        } catch {
            showError(message: "Error decoding forecast data", presenter: presenter)
            completion(nil)
        }
    }.resume()
}
