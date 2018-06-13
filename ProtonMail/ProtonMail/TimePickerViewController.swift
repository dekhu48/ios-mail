//
//  TimePickerViewController.swift
//  ProtonMail
//
//  Created by Anatoly Rosencrantz on 13/06/2018.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
final class TimePickerViewController: UIViewController {
    typealias ChangeHandler = (SelectedComponents)->Void
    typealias SelectedComponents = DateComponents
    
    @IBOutlet weak var picker: UIDatePicker!
    private var handler: ChangeHandler!
    private var valueToSelect: SelectedComponents!
    
    convenience init(select: SelectedComponents, changeHandler handler: @escaping ChangeHandler) {
        self.init(nibName: "\(TimePickerViewController.self)", bundle: .main)
        self.handler = handler
        self.valueToSelect = select
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Calendar.current.date(bySettingHour: self.valueToSelect.hour!,
                                         minute: self.valueToSelect.minute!,
                                         second: 0,
                                         of: Date())!
        self.picker.setDate(date, animated: false)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self.picker.date)
        self.handler(components)
        self.dismiss(animated: true, completion: nil)
    }
}
