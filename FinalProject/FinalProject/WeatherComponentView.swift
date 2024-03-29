//
//  WeatherComponentView.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/25/24.
//

import UIKit

@IBDesignable
final class WeatherComponentView: UIView {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var iconDescription: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "WeatherComponentView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func configureView(icon: UIImage, description: String) {
        self.weatherIcon.image = icon
        self.weatherIcon.tintColor = .yellow
        self.iconDescription.text = description
    }
    
    func configureView(description: String) {
        self.iconDescription.text = description
    }

}
