//
//  TIRegisterViewController.swift
//  Ticas
//
//  Created by Guy Kahlon on 3/22/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit
import MobileCoreServices


struct ParseKeys {
    static let Pilotname     = "PilotName"
    static let AircraftType  = "Aircraft"
    static let AircraftImage = "AircraftImage"
    static let PilotImage    = "PilotName"
}

struct ParseErrorKyes{
    static let UserAlreadyExist         = 202
    static let LoginInvalidCredentials  = 101
    static let InvalidEmail             = 125
}

class TIRegisterViewController: UIViewController {

    @IBOutlet weak var pilotImageView: UIImageView!
    @IBOutlet weak var aircraftImageView: UIImageView!
    @IBOutlet weak var callSignTextField: UITextField!
    @IBOutlet weak var pilotNameTextField: UITextField!
    @IBOutlet weak var aircraftTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var callSign: String?
    private var pilotName: String?
    private var aircraftType: String?
    private var pilot: UIImage?
    private var aircraft: UIImage?
    private var currentImageView: UIImageView?
    
    @IBOutlet weak var pilotImageGesture: UITapGestureRecognizer!
    @IBOutlet var aircraftImageGesture: UITapGestureRecognizer!
    
    @IBAction func openCameraPicker(sender: UITapGestureRecognizer) {
        showChoosePhotoActionSheet()
        switch sender{
            case pilotImageGesture:
                currentImageView = pilotImageView
            case aircraftImageGesture:
                currentImageView = aircraftImageView
            default: break            
        }
    }
    
    @IBAction func handelTapGesture(sender: UITapGestureRecognizer) {
    
        callSignTextField.resignFirstResponder()
        pilotNameTextField.resignFirstResponder()
        aircraftTextField.resignFirstResponder()
    }
    

    
    @IBAction func register() {
        if let callSignValue = callSign{
            
            self.activityIndicatorView.startAnimating()
            var user = PFUser()
            user.username  = callSignValue
            user.password  = callSignValue
            
            if let pilot = pilotName{
                user[ParseKeys.Pilotname] = pilot
            }
            
            if let aircraft = aircraftType{
                user[ParseKeys.AircraftType] = aircraft
            }
            
            //TODO - Add images
            
            user.signUpInBackgroundWithBlock({ (succeeded:Bool, error: NSError?) -> Void in
                
                if (succeeded) {
                    
                    println("Register successfull")
                    self.gotoMainMap()
                    var installation:PFInstallation = PFInstallation.currentInstallation()
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackgroundWithBlock({ (flage :Bool, error :NSError?) -> Void in
                        println("\(error)")
                    })
                }
                else{
                    var errorMessage = String()
                    if error!.code == ParseErrorKyes.UserAlreadyExist
                    {
                        errorMessage = "User name already exist, Please try again"
                    }
                    if error!.code == ParseErrorKyes.InvalidEmail
                    {
                        errorMessage = "Invalid email, Please try again"
                    }
                    
                    var loginAlert:UIAlertController = UIAlertController(title: "Register Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    loginAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil))
                    self.presentViewController(loginAlert, animated: true, completion: nil)
                }
                self.activityIndicatorView.stopAnimating()                
            })
        }
    }
    
    private func gotoMainMap(){
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let front =  storyboard?.instantiateViewControllerWithIdentifier("Main view conroller") as? UIViewController
        appDelegate.window?.rootViewController?.presentViewController(front!, animated: true, completion: nil)
    }
    
    private func showChoosePhotoActionSheet(){
        
        var loginAlert:UIAlertController = UIAlertController(title: "Location Photo",
            message: "Please choose photo",
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        loginAlert.addAction(UIAlertAction(title: "Cancel",
            style: .Cancel, handler: {
            alertAction in
                
        }))
        
        loginAlert.addAction(UIAlertAction(title: "Take Photo",
            style: .Default, handler: {
            alertAction in
            
            var imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.mediaTypes = NSArray(object: kUTTypeImage) as [AnyObject]
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            imagePicker.cameraDevice = .Front
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        
        loginAlert.addAction(UIAlertAction(title: "Coose Existing Photo",
            style: .Default, handler: {
            alertAction in
            
            var imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
    }
}

extension TIRegisterViewController: UITextFieldDelegate{
    
    func textFieldDidEndEditing(textField: UITextField){
        switch textField{
            case callSignTextField:
                callSign = textField.text
            case pilotNameTextField:
                pilotName = textField.text
            case aircraftTextField:
                aircraftType = textField.text
            default: break
        }
    }
}

extension TIRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        currentImageView?.image = pickedImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}







