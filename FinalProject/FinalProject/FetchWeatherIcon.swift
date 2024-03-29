//
//  FetchWeatherIcon.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/26/24.
//
import UIKit


func constructWeatherIconURL(iconId: String) -> URL {
    let iconURLAsString = "https://openweathermap.org/img/wn/" + iconId + "@2x.png"
    return URL(string: iconURLAsString)!
}

func downloadWeatherIcon(from url: URL, weatherImageView: UIImageView!, presenter: UIViewController?) {
    URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let data = data {
            DispatchQueue.main.async {
                weatherImageView.image = UIImage(data: data)
            }
        } else {
            print("Error downloading image")
            showError(message: "Error downloading image", presenter: presenter)
        }
    }.resume()
}
