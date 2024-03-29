//
//  ShowError.swift
//  FinalProject
//
//  Created by Giorgi Zangurashvili on 2/26/24.
//

import UIKit

func showError(message: String, presenter: UIViewController?) {
    let error = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
    error.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    presenter?.present(error, animated: true, completion: nil)
}
