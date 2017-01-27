//
//  RLocationHelper.swift
//  Ridap
//
//  Created by Manh Le on 26/1/17.
//  Copyright © 2017 Xuan Manh Le. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit

class RLocationHelper: NSObject {
    
    static let shared = RLocationHelper()
    
    func locationOf(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func regionOf(location: CLLocation) -> MKCoordinateRegion {
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        return region
    }
    
    func annotation(coordinate: CLLocationCoordinate2D, title: String, subTitle: String, id: String, image: UIImage?) -> RCustomPointAnnotation {
        let an = RCustomPointAnnotation()
        an.coordinate = coordinate
        an.title = title
        an.subtitle = subTitle
        an.identifier = id
        an.image = image
        return an
    }
    
    func annotationView(annotation: RCustomPointAnnotation, mapView: MKMapView) -> MKAnnotationView {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation,
                                              reuseIdentifier: annotation.identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }
        annotationView!.image = annotation.image
        return annotationView!
    }
    
    func drawRouteFrom(sourceLocation: CLLocationCoordinate2D,
                       destLocation: CLLocationCoordinate2D,
                       view: MKMapView,
                       sourceImg: UIImage?,
                       destImg: UIImage?) {
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destPlacemark = MKPlacemark(coordinate: destLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        
        let sourceAnnotation = annotation(coordinate: (sourcePlacemark.location?.coordinate)!,
                                          title: parseAddress(selectedItem: sourcePlacemark),
                                          subTitle: "",
                                          id: "source",
                                          image: UIImage(named: "source"))
        let destAnnotation = annotation(coordinate: (destPlacemark.location?.coordinate)!,
                                        title: parseAddress(selectedItem: destPlacemark),
                                        subTitle: "",
                                        id: "destination",
                                        image: UIImage(named: "destination"))
        view.removeAnnotations(view.annotations)
        view.addAnnotations([sourceAnnotation, destAnnotation])
        view.removeOverlays(view.overlays)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            
            let route = response.routes[0]
            view.addOverlays([route.polyline], level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            view.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        // put a space
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil)
            && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ",  " : ""
        
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(format: "%@%@%@%@%@%@ %@",
                                 //street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            //street name
            selectedItem.thoroughfare ?? "",
            comma,
            //city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? "")
        
        return addressLine
    }
}

extension CLLocation {
  func placeMark() -> MKPlacemark {
    return MKPlacemark(coordinate: self.coordinate)
  }
}

