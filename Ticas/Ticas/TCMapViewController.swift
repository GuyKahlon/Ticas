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
    var numberOfCrew: Int?
    var trafficFrequency:String?
    var departed: String?
    var destination: String?
}

class TCMapViewController: UIViewController {

    var radiusFirstCircle: CLLocationDistance  =  Double(1000)
    var radiusSecondCircle: CLLocationDistance =  Double(2000)
    var radiusThirdCircle: CLLocationDistance  =  Double(3000)
    var status:PFObject = PFObject(className: ParseStatus.StatusCalssName)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var callSignLabel: UILabel!{
        didSet{
            callSignLabel.text = PFUser.currentUser()?[ParseKeys.CallSign] as? String ?? "--"
        }
    }
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var altitudeLable: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var trafficFrquency: UILabel!
    
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
            startButton.selected = false
            startButton.backgroundColor = UIColor.blueColor()
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
                    flightInfo!.trafficFrequency = setupFlightVC.trafficFrequency
                    flightInfo!.destination = setupFlightVC.destination
                    flightInfo!.departed = setupFlightVC.departed
                    flightInfo!.numberOfPassengers = setupFlightVC.numberOfPassengers
                    flightInfo!.numberOfCrew = setupFlightVC.numberOfCrew
                    
                    
                    trafficFrquency.text = setupFlightVC.trafficFrequency
                    startButton.selected = true
                    startButton.backgroundColor = UIColor.redColor()
                }
            }
        }
    }
    
    var aircraftes = [String:PFObject]()
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

    func loadAircraft(fromLocation:CLLocation, radiusDistance:CLLocationDistance){
        
        var query = PFQuery(className:ParseStatus.StatusCalssName)
        
        query.whereKey("geoPoint", nearGeoPoint: PFGeoPoint(latitude: fromLocation.coordinate.latitude, longitude: fromLocation.coordinate.longitude), withinKilometers: 3000/1000)
        
        query.whereKey(ParseStatus.Creator, notEqualTo: PFUser.currentUser())
        query.includeKey(ParseStatus.Creator)
        
        query.findObjectsInBackgroundWithBlock { (statuses: [AnyObject]!, error: NSError!) -> Void in
            
            println("loadAircraft : \(statuses?.count)")
            
            var airCraft = [String:PFObject]()
            for status in statuses{
                if let oStatus = status as? PFObject{
                    if let air = self.aircraftes[oStatus.objectId]{
                        let location: PFGeoPoint  = status["geoPoint"] as PFGeoPoint
                        let locationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                        air.setCoordinate(locationCoordinate)
                        airCraft[oStatus.objectId] = oStatus
                        self.aircraftes[oStatus.objectId] = nil
                    }
                    else{
                        airCraft[oStatus.objectId] = oStatus
                        self.mapView.addAnnotation(oStatus)
                    }
                }
            }
            
            //println("old Aircraft : \(self.aircraftes.count)")
            //println("new Aircraft : \(airCraft.count)")
            
            
            for (key, oldAir) in self.aircraftes{
                
                for a in self.mapView.annotations{
                    if let b = a as? PFObject{
                        if b.objectId == oldAir.objectId{
                            self.mapView.removeAnnotation(b)
                        }
                    }
                }
                
                //println("objectId : \(oldAir.objectId)")
                //println("Map annotations : \(self.mapView.annotations.count)")
                //self.mapView.removeAnnotation(oldAir)
                //println("Map annotations : \(self.mapView.annotations.count)")
            }
            
            self.aircraftes = airCraft
            
            //println("Aircraft = \(statuses.count)")
            //self.mapView.removeAnnotations(self.mapView.annotations)
            //self.mapView.addAnnotations(Array(self.aircraftes.values))
        }
    }
}

extension PFObject: MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        
        let location: PFGeoPoint  = self["geoPoint"] as PFGeoPoint
        let locationCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        return locationCoordinate
    }
    
    public var title: String {
        
        return "Aircraft \(objectId)"
    }
    public func setCoordinate(newCoordinate: CLLocationCoordinate2D){
        //willChangeValueForKey("coordinate")
        let geoPoint = PFGeoPoint(latitude:newCoordinate.latitude,
            longitude:newCoordinate.longitude)
        self["geoPoint"] = geoPoint
        //didChangeValueForKey("coordinate")
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
        
        //var status:PFObject = PFObject(className: ParseStatus.StatusCalssName)
        
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
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!){
        
        //println("MapView didUpdateUserLocation")
        if let lastLocation = lastFetchLocation{
            if let userLocation = mapView.userLocation.location {
                updateStatus(userLocation)
                
                let meters = lastLocation.distanceFromLocation(userLocation)
                
                if meters > radiusFirstCircle/5{
                    lastFetchLocation =  userLocation
                    addRadiusOverlay(radiusFirstCircle, coordinate: userLocation.coordinate,zoom:true)
                }
                loadAircraft(userLocation, radiusDistance: radiusThirdCircle)
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
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if let treasure = annotation as? PFObject {
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as MKPinAnnotationView!
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                view.canShowCallout = true
                view.animatesDrop = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
                
                let icon = UIImage.hgImaheFromString("✈️")
                view?.image = icon
                view?.canShowCallout = true
                view?.animatesDrop = false
                
            } else {
                view.annotation = annotation
            }
            
            //view.pinColor = treasure.pinColor()
            
            return view
        }
        return nil
    }
}

extension UIImage{
    
    class func hgImaheFromString(str: NSString)-> UIImage{
        
        var label = UILabel()
        label.text = str
        label.font = UIFont(name: "Georgia", size: 30.0)!
        label.textAlignment = .Center
        label.layer.borderColor = UIColor.blackColor().CGColor
        label.opaque = false
        label.backgroundColor = UIColor.clearColor()
        var dic = [NSFontAttributeName:label.font]
        
        var measuredSize:CGSize =  str.sizeWithAttributes(dic)
        label.frame = CGRectMake(0, 0, measuredSize.width * 1, measuredSize.height * 1)
        var img:UIImage = UIImage.ghImageFromView(label)
        return img
    }
    
    class func ghImageFromView(view: UIView)-> UIImage{
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        var img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return img;
    }
}


