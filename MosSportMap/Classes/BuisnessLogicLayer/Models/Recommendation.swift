//
//  Recommendation.swift
//  MosSportMap
//
//  Created by Sergeyd on 22.10.2021.
//

import GoogleMapsUtils

struct Rectangle {
    let topLeft: CLLocationCoordinate2D
    let bottomRight: CLLocationCoordinate2D
}

struct Recommendation {
    let availabilityType: SportObject.AvailabilityType
    let missingTypes: [SportType]
    let existObjects: [SportObject]
    let coordinates: [CLLocationCoordinate2D]
}

enum RecommendationType {
    case area
    case availability(area: Population, polygon: GMSPolygon)
    case objects(area: Population, availability: SportObject.AvailabilityType, recommendation: Recommendation)
}