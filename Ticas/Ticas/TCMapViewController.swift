//
//  TCMapViewController.swift
//  Ticas
//
//  Created by Guy Kahlon on 3/22/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit
import MapKit

class Flight {
    var numberOfPassengers: Int?
    var callSign:String?
    var origin: String?
    var destination: String?
}

class TCMapViewController: UIViewController {

    var radiusFirstCircle: CLLocationDistance  =  Double(1000)
    var radiusSecondCircle: CLLocationDistance =  Double(2000)
    var radiusThirdCircle: CLLocationDistance  =  Double(3000)
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callSignLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLable: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    lazy private var locationManager: CLLocationManager = {
        var lezyLocationManager = CLLocationManager()
        lezyLocationManager.delegate = self;
        lezyLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        return lezyLocationManager
    }()
    
    var flightInfo:Flight?
    
    private var lastFetchLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch CLLocationManager.authorizationStatus(){
            case .AuthorizedWhenInUse, .AuthorizedWhenInUse:
                mapView.showsUserLocation = true
                locationManager.startUpdatingLocation()
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .Restricted, .Denied:
                let alertController = UIAlertController(
                    title: "Want to enjoy more usable features ?",
                    message: "In order to see Places near you, please open this app's settings and set location access to 'While Using the App'.",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(openAction)
                presentViewController(alertController, animated: true, completion: nil)
            default: break;
        }
    }
    
    @IBAction func startFlightButtonAction(sender: UIButton) {
    
        if sender.selected{
            //Stop
        }
        else{
            //Setup Flight
            performSegueWithIdentifier("popOverSetupFlightSegue",
                sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "popOverSetupFlightSegue" {
            if let controller = segue.destinationViewController as? UIViewController {
                controller.popoverPresentationController?.delegate = self
                //controller.preferredContentSize = CGSize(width: 320, height: 186)
            }
        }
    }
    
    //pragma mark - Unwind Seques
    @IBAction func setupFlight(segue: UIStoryboardSegue) {
        if let identifier = segue.identifier {
            if identifier == "flightInfoSegue"{
                if let setupFlightVC = segue.sourceViewController as? TCSetupFlightViewController{
                
                    flightInfo = Flight()
                    flightInfo!.callSign = setupFlightVC.callSign
                    flightInfo!.destination = setupFlightVC.destination
                    flightInfo!.origin = setupFlightVC.origin
                    flightInfo!.numberOfPassengers = setupFlightVC.numberOfPassengers
                    
                    callSignLabel.text = setupFlightVC.callSign
                    startButton.selected = true
                }
            }
        }
    }
}

extension TCMapViewController: UIPopoverPresentationControllerDelegate{

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController!) -> UIModalPresentationStyle {
        return .None
    }
    
}

extension TCMapViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        if status == .AuthorizedWhenInUse || status == .AuthorizedWhenInUse{
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        
//        println("location Manager")
//        if let newLocation = locations.first as? CLLocation{
//            println("Speed = %f", newLocation.speed);
//        }
        
       

    }
    
//    func addRadiusOverlays(){
//        
//    }
//    func addRadiusOverLays(coordinate: CLLocationCoordinate2D,
//        radiuses:[CLLocationDistance],
//        zoom: Bool = false){
//        
//            
//            
//            
//    }
    
    func addRadiusOverlay(radiusDistance:CLLocationDistance,
        coordinate: CLLocationCoordinate2D,
        zoom:Bool = false){
            
            let circle1 = MKCircle(centerCoordinate: coordinate, radius: radiusFirstCircle)
            let circle2 = MKCircle(centerCoordinate: coordinate, radius: radiusSecondCircle)
            let circle3 = MKCircle(centerCoordinate: coordinate, radius: radiusThirdCircle)
            
            dispatch_async(dispatch_get_main_queue(),{
                self.mapView.removeOverlays(self.mapView.overlays)
                self.mapView.addOverlays([circle1,circle2,circle3])
                if zoom{
                    let mapRegion :MKCoordinateRegion = MKCoordinateRegion(center: coordinate,
                        span: MKCoordinateSpanMake(self.radiusThirdCircle/40000, self.radiusThirdCircle/40000))
                    self.mapView.setRegion(mapRegion, animated: true)
                }
            });
    }
    
    struct ParseStatus {
        static let StatusCalssName = "updateStatus"
        static let GeoPoint        = "geoPoint"
        static let Creator         = "user"
        static let Press           = "press"
        static let Direction       = "direction"
        static let Velocity        = "velocity"
        static let Altitude        = "altitude"
    }
}

extension TCMapViewController: MKMapViewDelegate{

    private func circleColorforRadius(radius:CLLocationDistance)->UIColor?{
        switch radius{
            case radiusFirstCircle:return UIColor.redColor()
            case radiusSecondCircle: return UIColor.orangeColor()
            case radiusThirdCircle: return UIColor.blueColor()
            default: return nil
        }
    }
    
    private func updateStatus(location: CLLocation){
        
        var status:PFObject = PFObject(className: ParseStatus.StatusCalssName)
        
        let geoPoint = PFGeoPoint(latitude:location.coordinate.latitude,
            longitude:location.coordinate.longitude)
        
        status[ParseStatus.GeoPoint] = geoPoint
        status[ParseStatus.Creator]  = PFUser.currentUser()
        status[ParseStatus.Velocity] = location.speed
        status[ParseStatus.Direction] = location.course
        status[ParseStatus.Direction] = location.altitude
        
        var acl:PFACL = PFACL(user: PFUser.currentUser()!)
        acl.setPublicReadAccess(true)
        status.ACL = acl
        
        status.saveEventually { (success:Bool,error: NSError?) -> Void in
            if let saveError = error{
                println("Fails to save status update")
            }
        }
        
        
        courseLabel.text = location.course.description
        altitudeLable.text = (location.altitude * 3.2808399).description
        speedLabel.text = location.speed.description + " kts"
        
    }
    
    func mapView(mapView: MKMapView!,
        rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!{
        
        if let circle = overlay as? MKCircle{
            var circleR = MKCircleRenderer(circle: circle)
            circleR.fillColor = UIColor(white: 0.4, alpha: 0.2)
            circleR.strokeColor = circleColorforRadius(circle.radius)
            circleR.lineWidth = 1.0
            return circleR;
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!,viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!{
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState){
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!){
    }
    
    func mapViewDidStopLocatingUser(mapView: MKMapView!){
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!){
        
        println("MapView didUpdateUserLocation")
        if let lastLocation = lastFetchLocation{
            if let userLocation = mapView.userLocation.location {
                updateStatus(userLocation)
                
                let meters = lastLocation.distanceFromLocation(userLocation)
                
                if meters > radiusFirstCircle/5{
                    lastFetchLocation =  userLocation
                    addRadiusOverlay(radiusFirstCircle, coordinate: userLocation.coordinate,zoom:true)
                }
            }
        }
        else{
            if let userLocation = mapView.userLocation.location{
                lastFetchLocation =  userLocation
                addRadiusOverlay(self.radiusFirstCircle,
                    coordinate: userLocation.coordinate,
                    zoom:true)
            }
        }

    }
//        mapView.userLocation.title = ""
//        if mapView.userLocation.location != nil{
        
//            if let lastOptionalFetchLocation = lastFetchLocation{
//                
//                let meters:CLLocationDistance = lastOptionalFetchLocation.distanceFromLocation(map.userLocation.location)
//                
//                if meters > radius{
//                    loadPlaces(map.userLocation.location, radiusDistance:radius)
//                    addRadiusOverlay(self.radius, coordinate: map.userLocation.location.coordinate)
//                }
//                else{
//                    println("\(meters) d \(radius)")
//                }
//            }
//            else{
//                addRadiusOverlay(self.radius,
//                    coordinate: map.userLocation.location.coordinate,
//                    zoom: true)
//            }
//        }
//   }
    
//    func mapView(mapView: MKMapView!, didFailToLocateUserWithError error: NSError!){
//    }
}






