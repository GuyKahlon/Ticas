//
//  TCSetupFlightViewController.swift
//  Ticas
//
//  Created by Guy Kahlon on 3/23/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit

class TCSetupFlightViewController: UIViewController {

    var numberOfPassengers: Int?{
        get{
            if let passengers = passengersTextField.text{
                return passengers.toInt()
            }
            else{
                return nil
            }
        }
    }
    
    var numberOfCrew: Int?{
        get{
            if let passengers = crewTextField.text{
                return passengers.toInt()
            }
            else{
                return nil
            }
        }
    }
    var trafficFrequency:String?{
        get{
            return trafficFrequencyTextField.text
        }
    }
    var departed: String?{
        get{
            return departedTextField.text
        }
    }
    var destination: String?{
        get{
            return destinationTextField.text
        }
    }
    
    @IBOutlet private weak var trafficFrequencyTextField: UITextField!
    @IBOutlet private weak var passengersTextField: UITextField!
    @IBOutlet private weak var crewTextField: UITextField!
    @IBOutlet private weak var departedTextField: UITextField!
    @IBOutlet private weak var destinationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
