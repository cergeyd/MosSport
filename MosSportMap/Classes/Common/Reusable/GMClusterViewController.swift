//
//  GMClusterViewController.swift
//  MosSportMap
//
//  Created by Sergeyd on 22.10.2021.
//

import GoogleMapsUtils

class GMClusterViewController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
    
    struct Config {
        static let bucketsCount = 100
        static let clusterDistance: UInt = 100
        static let initialCoordinates = CLLocationCoordinate2D(latitude: 55.71, longitude: 37.62)
        static let zoomLevel: Float = 15.0
    }
    
    /// Карта
    lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: Config.initialCoordinates.latitude, longitude: Config.initialCoordinates.longitude, zoom: Config.zoomLevel)
        let _mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        _mapView.delegate = self
        self.view.addSubview(_mapView)
        return _mapView
    }()
    /// Объекты на карте
    lazy var clusterManager: GMUClusterManager = {
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [NSNumber(value: Config.bucketsCount)], backgroundColors: [AppStyle.color(for: .coloured)])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(clusterDistancePoints: Config.clusterDistance)!
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        let _clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
        _clusterManager.setMapDelegate(self)
        return _clusterManager
    }()
    /// Тепловая карта
    lazy var heatmapLayer: GMUHeatmapTileLayer = {
        let gradientColors = [UIColor.green, UIColor.red]
        let gradientStartPoints = [0.2, 1.0] as [NSNumber]
        let _heatmapLayer = GMUHeatmapTileLayer()
        //_heatmapLayer.radius = 40
        _heatmapLayer.maximumZoomIntensity = 25
        _heatmapLayer.opacity = 0.8
        _heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 156)
        return _heatmapLayer
    }()
    /// Данные о численности населения
    lazy var parser: GMUKMLParser = {
        let path = Bundle.main.path(forResource: "mo", ofType: "kml")!
        let url = URL(fileURLWithPath: path)
        let _parser = GMUKMLParser(url: url)
        _parser.parse()
        return _parser
    }()
    /// Отрисовка границ
    lazy var render: GMUGeometryRenderer = {
        let _render = GMUGeometryRenderer(map: self.mapView, geometries: self.parser.placemarks, styles: self.parser.styles, styleMaps: self.parser.styleMaps)
        return _render
    }()
}
