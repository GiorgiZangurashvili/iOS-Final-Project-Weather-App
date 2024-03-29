//
//  ForecastViewController.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/24/24.
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var forecastTable: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var blurView: UIVisualEffectView!
    let locationManager = CLLocationManager()
    var forecastByDayOfTheWeek: [WeekDay: [WeatherForecast]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        let refreshButton = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshAction)
        )

        navigationItem.leftBarButtonItem = refreshButton
        view.bringSubviewToFront(spinner)
        forecastTable.dataSource = self
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                self.blurView.alpha = 0
            }
            guard let location = self.locationManager.location else { return }
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            fetchForecastData(latitude: latitude, longitude: longitude, presenter: self) { [weak self] forecastResponse in
                guard let self = self else { return }
                if let forecastData = forecastResponse {
                    self.forecastByDayOfTheWeek = self.createDataSource(forecastData.list)
                    DispatchQueue.main.async {
                        self.forecastTable.reloadData()
                    }
                }
            }
            self.spinner.stopAnimating()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = WeekDay(rawValue: section + 1)!
        return forecastByDayOfTheWeek[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        let date = WeekDay(rawValue: indexPath.section + 1)!
        if let forecasts = forecastByDayOfTheWeek[date] {
            let forecast = forecasts[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = dateFormatter.date(from: forecast.dt_txt) {
                dateFormatter.dateFormat = "HH:mm"
                cell.currentTime.text = dateFormatter.string(from: date)
            }
            cell.weatherDescription.text = forecast.weather.first?.description
            cell.temperature.text = "\(Int((forecast.main.temp - 273.15).rounded()))°C"
            
            if let iconId = forecast.weather.first?.icon {
                let iconURL = constructWeatherIconURL(iconId: iconId)
                downloadWeatherIcon(from: iconURL, weatherImageView: cell.weatherIconImageView, presenter: self)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let title = WeekDay(rawValue: section + 1)?.name() {
            return title
        } else {
            return ""
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return forecastByDayOfTheWeek.keys.count
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        fetchForecastData(latitude: latitude, longitude: longitude, presenter: self) { [weak self] forecastResponse in
            guard let self = self else { return }
            if let forecastData = forecastResponse {
                self.forecastByDayOfTheWeek = self.createDataSource(forecastData.list)
                DispatchQueue.main.async {
                    self.forecastTable.reloadData()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(message: "Failed to find user's location", presenter: self)
    }
    
    enum WeekDay: Int {
        case Monday = 1, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
        
        func name() -> String {
            switch self {
            case .Monday: return "Monday"
            case .Tuesday: return "Tuesday"
            case .Wednesday: return "Wednesday"
            case .Thursday: return "Thursday"
            case .Friday: return "Friday"
            case .Saturday: return "Saturday"
            case .Sunday: return "Sunday"
            default: return ""
            }
        }
    }
    
    func getWeekDay(from dateString: String) -> WeekDay {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = dateFormatter.date(from: dateString)
        let calendar = Calendar.current
        let weekDay = calendar.component(.weekday, from: date!)
        
        return WeekDay(rawValue: weekDay) ?? WeekDay.Monday
    }
    
    func createDataSource(_ forecasts: [WeatherForecast]) -> [WeekDay: [WeatherForecast]] {
        var forecastDict = [WeekDay: [WeatherForecast]]()
        
        for forecast in forecasts {
            let weekDay = getWeekDay(from: forecast.dt_txt)
            if forecastDict[weekDay] == nil {
                forecastDict[weekDay] = [forecast]
            } else {
                forecastDict[weekDay]?.append(forecast)
            }
        }
        
        for (key, value) in forecastDict {
            forecastDict[key] = value.sorted { $0.dt_txt < $1.dt_txt }
        }
        
        let sortedForecastDict = forecastDict.sorted { $0.key.rawValue < $1.key.rawValue }
        
        var result = [WeekDay: [WeatherForecast]]()
        for (key, value) in sortedForecastDict {
            result[key] = value
        }
        
        return result
    }
}
