//
//  UIViewController+Extentions.swift
//  virtual-tourist
//
//  Created by Ischuk Alexander on 01.06.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(alertMessage: AlertMessage, buttonTitle: String, presenter: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertMessage.title, message: alertMessage.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            presenter.present(alert, animated: true)
        }
    }
    
    func getAlertDataFromError(error: ApiClient.ApiError) -> AlertMessage {
        switch error {
        case .networkError:
            return AlertMessage(title: "Network error", message: "Please, try again later")
        case .decodingError:
            return AlertMessage(title: "Decoding error", message: "Please, contact developer or try again later")
        }
    }
}


