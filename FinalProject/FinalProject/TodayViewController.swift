//
//  TodayViewController.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/24/24.
//

import UIKit
import CoreLocation

class TodayViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherInformationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    var blurView: UIVisualEffectView!
    let locationManager = CLLocationManager()
    var weatherDescription = ""
    
    @IBOutlet weak var rainView: WeatherComponentView!
    @IBOutlet weak var dropView: WeatherComponentView!
    @IBOutlet weak var celsiusView: WeatherComponentView!
    @IBOutlet weak var compassView: WeatherComponentView!
    @IBOutlet weak var windView: WeatherComponentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let rainingImage = UIImage(named: "raining")!
        self.rainView.configureView(icon: rainingImage, description: "10")
        self.dropView.configureView(icon: UIImage(named: "drop")!, description: "20")
        self.celsiusView.configureView(icon: UIImage(named: "celsius")!, description: "30")
        self.windView.configureView(icon: UIImage(named: "wind")!, description: "40")
        self.compassView.configureView(icon: UIImage(named: "compass")!, description: "50")
        
        
        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshAction)
        )
        
        navigationItem.leftBarButtonItem = refreshButton
        
        let shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareWeatherDescription)
        )
        
        navigationItem.rightBarButtonItem = shareButton
        
        let blurEffect = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        view.addSubview(blurView)
        view.addSubview(spinner)
    }
    
    @objc func refreshAction() {
        UIView.animate(withDuration: 0.3) {
            self.blurView.alpha = 1
        }
        spinner.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0
            }
            guard let location = self.locationManager.location else { return }
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            fetchWeatherData(latitude: latitude, longitude: longitude, presenter: self) { [weak self] weatherData in
                guard let self = self else { return }
                if let weatherData = weatherData {
                    self.updateUI(with: weatherData)
                } else {
                    showError(message: "Failed to fetch weather data.", presenter: self)
                    self.refreshAction()
                }
            }
            self.spinner.stopAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
        fetchWeatherData(latitude: latitude, longitude: longitude, presenter: self) { [weak self] weatherData in
                guard let self = self else { return }
                if let weatherData = weatherData {
                    self.updateUI(with: weatherData)
                } else {
                    showError(message: "Failed to fetch weather data.", presenter: self)
                    self.refreshAction()
                }
            }
    }
    
    func updateUI(with weatherData: WeatherData) {
        DispatchQueue.main.async {
            self.cityLabel.text = weatherData.name
            self.rainView.configureView(description: "\(weatherData.clouds.all)%")
            self.dropView.configureView(description: "\(weatherData.main.humidity)%")
            self.celsiusView.configureView(description: "\(weatherData.main.pressure) hPA")
            self.windView.configureView(description: "\(weatherData.wind.speed) km/h")
            self.compassView.configureView(description: convertDegreesToDirection(degrees: weatherData.wind.deg))
            if let weather = weatherData.weather.first {
                let iconId = weather.icon
                let iconURL = constructWeatherIconURL(iconId: iconId)
                downloadWeatherIcon(from: iconURL, weatherImageView: self.weatherImageView, presenter: self)
                let temperature = Int((weatherData.main.temp - 273.15).rounded())
                self.weatherInformationLabel.text = "\(temperature)°C | " + weather.main
            }
            self.weatherDescription = weatherData.weather.description
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: "Failed to find user's location", presenter: self)
    }
    
    @objc func shareWeatherDescription() {
        let activityViewController = UIActivityViewController(activityItems: [self.weatherDescription], applicationActivities: nil)
        
        if let activityController = activityViewController.popoverPresentationController {
            activityController.sourceView = view
            activityController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            activityController.permittedArrowDirections = []
        }
        present(activityViewController, animated: true, completion: nil)
    }
}
