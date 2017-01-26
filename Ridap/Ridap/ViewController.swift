//
//  ViewController.swift
//  Ridap
//
//  Created by Xuan Manh Le on 26/1/17.
//  Copyright © 2017 Xuan Manh Le. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var routeBtn: UIButton!

  @IBOutlet weak var etaLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  
  @IBOutlet var routeScoreBtns: [UIButton]!
  
  @IBOutlet var etaScoreBtns: [UIButton]!
  
  var locationManager : CLLocationManager!
  
  var sourceLoc : CLLocation?
  var destLoc : CLLocation?
  
  var sourceAnnotation : RCustomPointAnnotation!
  var destAnnotation : RCustomPointAnnotation!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.setUpUI()
    self.addGesturesToMapView()
    self.mapView.delegate = self
    self.mapView.mapType = .standard
    self.locationManager = CLLocationManager()
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func routeBtnPressed(_ sender: UIButton) {
    if self.sourceLoc == nil || self.destLoc == nil {
      return
    }
    let sourcePlaceMark = MKPlacemark(coordinate: self.sourceLoc!.coordinate)
    let sourceItem = MKMapItem(placemark: sourcePlaceMark)
    let destPlaceMark = MKPlacemark(coordinate: self.destLoc!.coordinate)
    let destItem = MKMapItem(placemark: destPlaceMark)
    
    let request = MKDirectionsRequest()
    request.source = sourceItem
    request.destination = destItem
    request.requestsAlternateRoutes = true
    let direction = MKDirections(request: request)
    direction.calculateETA { (response, error) in
      if let response = response, error == nil {
        self.etaLabel.text = "\(Int(response.expectedTravelTime) / 60) mins away"
      }
    }
    RLocationHelper.shared.drawRouteFrom(sourceLocation: self.sourceLoc!.coordinate,
                                         destLocation: self.destLoc!.coordinate,
                                         view: self.mapView,
                                         sourceImg: UIImage(named: "source"),
                                         destImg: UIImage(named: "destination"))
  }
  @IBAction func routeScorePressed(_ sender: UIButton) {
  }

  @IBAction func etaScorePressed(_ sender: UIButton) {
  }
}

extension ViewController {
  
  func setUpUI() {
    for btn in self.routeScoreBtns {
      btn.layer.cornerRadius = btn.frame.width / 2.0
      btn.layer.borderColor = UIColor.white.cgColor
      btn.layer.borderWidth = 4.0
      btn.clipsToBounds = true
    }
    for btn in self.etaScoreBtns {
      btn.layer.cornerRadius = btn.frame.width / 2.0
      btn.layer.borderColor = UIColor.white.cgColor
      btn.layer.borderWidth = 4.0
      btn.clipsToBounds = true
    }
    routeBtn.layer.cornerRadius = routeBtn.frame.width / 2.0
    routeBtn.layer.borderWidth = 4.0
    routeBtn.layer.borderColor = UIColor.white.cgColor
    routeBtn.clipsToBounds = true
    
    self.etaLabel.text = "ETA"
    self.distanceLabel.text = "Distance"
  }
  
  func addGesturesToMapView() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapViewTapped(_:)))
    self.mapView.addGestureRecognizer(tapGesture)
    self.mapView.isUserInteractionEnabled = true
  }
  
  func mapViewTapped(_ sender: UITapGestureRecognizer) {
    let point = sender.location(in: self.mapView)
    let location = self.mapView.convert(point, toCoordinateFrom: self.mapView)
    self.destLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
    if self.destAnnotation != nil {
      self.mapView.removeAnnotation(self.destAnnotation)
    }
    self.destAnnotation = RCustomPointAnnotation()
    self.destAnnotation.identifier = "destination"
    self.destAnnotation.image = UIImage(named: "destination")
    self.destAnnotation.title = "Destination"
    self.destAnnotation.subtitle = RLocationHelper.shared.parseAddress(selectedItem: self.destLoc!.placeMark())
    self.mapView.addAnnotation(self.destAnnotation)
  }
}

extension ViewController : MKMapViewDelegate, CLLocationManagerDelegate {
  
  func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    if let location = userLocation.location {
      self.sourceLoc = location
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)
    renderer.lineWidth = 10.0
    renderer.strokeColor = UIColor.green
    
    return renderer
  }
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let customAnnotation = annotation as? RCustomPointAnnotation else {
      return nil
    }
    return RLocationHelper.shared.annotationView(annotation: customAnnotation, mapView: mapView)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      self.sourceLoc = location
      if self.sourceAnnotation != nil {
        self.mapView.removeAnnotation(self.sourceAnnotation)
      }
      self.sourceAnnotation = RCustomPointAnnotation()
      self.sourceAnnotation.identifier = "source"
      self.sourceAnnotation.image = UIImage(named: "source")
      self.sourceAnnotation.title = "Source"
      self.sourceAnnotation.subtitle = RLocationHelper.shared.parseAddress(selectedItem: self.sourceLoc!.placeMark())
      self.mapView.addAnnotation(self.sourceAnnotation)
      
      let region = RLocationHelper.shared.regionOf(location: self.sourceLoc!)
      self.mapView.setRegion(region, animated: true)
      self.locationManager.stopUpdatingLocation()
    }
  }
}

