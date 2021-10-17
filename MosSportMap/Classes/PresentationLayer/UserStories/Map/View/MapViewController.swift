//
//  MapMapViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import UIKit
import GoogleMapsUtils

protocol MapViewDataSource: AnyObject {
    func didCalculated(report: SquareReport)
}

class MapViewController: UIViewController {

    struct Config {
        static let bucketsCount = 100
        static let clusterDistance: UInt = 100
        static let initialCoordinates = CLLocationCoordinate2D(latitude: 55.71, longitude: 37.62)
        static let zoomLevel: Float = 10.0
    }

    var output: MapViewOutput!

    /// Сохраняем последнее значения овердея, чтобы вернуть
    private var lastSelectedPolygon: GMSPolygon?
    /// Контроллеры, которым мы расскажим о наших действах
    private var dataSources: [MapViewDataSource] = []
    /// Если карта, необходима для выбора границ к отчёту
    var calculateAreaType: CalculateAreaType?
    /// Полигон, для рисования вручную
    private var drawPolygon = GMSMutablePath()
    private var polygons: [GMSPolygon] = []
    private var coordinates: [CLLocationCoordinate2D] = []
    /// Карта
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: Config.initialCoordinates.latitude, longitude: Config.initialCoordinates.longitude, zoom: Config.zoomLevel)
        let _mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        _mapView.delegate = self
        self.view.addSubview(_mapView)
        return _mapView
    }()
    /// Объекты на карте
    private lazy var clusterManager: GMUClusterManager = {
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [NSNumber(value: Config.bucketsCount)], backgroundColors: [AppStyle.color(for: .coloured)])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm(clusterDistancePoints: Config.clusterDistance)!
        let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
        let _clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
        _clusterManager.setMapDelegate(self)
        return _clusterManager
    }()
    /// Тепловая карта
    private lazy var heatmapLayer: GMUHeatmapTileLayer = {
        let gradientColors = [UIColor.green, UIColor.red]
        let gradientStartPoints = [0.2, 1.0] as [NSNumber]
        let _heatmapLayer = GMUHeatmapTileLayer()
        _heatmapLayer.radius = 50
        _heatmapLayer.opacity = 0.8
        _heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 64)
        return _heatmapLayer
    }()
    /// Данные о численности населения
    private lazy var parser: GMUKMLParser = {
        let path = Bundle.main.path(forResource: "mo", ofType: "kml")!
        let url = URL(fileURLWithPath: path)
        let _parser = GMUKMLParser(url: url)
        _parser.parse()
        return _parser
    }()
    /// Отрисовка границ
    private lazy var render: GMUGeometryRenderer = {
        let _render = GMUGeometryRenderer(map: self.mapView, geometries: self.parser.placemarks, styles: self.parser.styles, styleMaps: self.parser.styleMaps)
        return _render
    }()

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        /// Вначале покажем кластеры
        self.makeClusters(hidden: false)
    }

    //MARK: Private func
    private func configureNavigationButtons() {
        if let splitController = self.splitViewController {
            if let navController = splitController.viewControllers.last as? UINavigationController {
                navController.topViewController?.navigationItem.leftBarButtonItem = splitController.displayModeButtonItem
            }
        }
    }

    //MARK: Виды карт
    /// Тепловая карта спортивных объектов
    private func makeHeatmap(hidden: Bool) {
        if (hidden) { self.heatmapLayer.map = nil; return }
        var list = [GMUWeightedLatLng]()
        for object in sportObjectResponse.objects {
            list.append(GMUWeightedLatLng(coordinate: object.coorditate, intensity: 1))
        }
        self.heatmapLayer.weightedData = list
        self.heatmapLayer.map = mapView
    }

    /// Границы Москвы
    private func makeBorders(hidden: Bool) {
       // var qwe: Set<PopulationSquares> = []

        if (hidden) {
            self.render.clear()
        } else {
            let mapOverlays = self.render.mapOverlays() ?? []
            if (mapOverlays.isEmpty) {
                self.render.render()
              //  Dispatch.main {
                    for overlay in self.render.mapOverlays() as! [GMSPolygon] {
                        let populationColor = SharedManager.shared.calculateColor(for: overlay.title)

//                        if let pop = SharedManager.shared.population(by: overlay.title!) {
//                            qwe.insert(PopulationSquares(area: pop.area, population: pop.population, square: overlay.area()!))
//                        }
                      
                        overlay.fillColor = populationColor
                        overlay.strokeColor = .black
                        overlay.strokeWidth = 1.0
                    }
              //  }
            }
        }
       // self.save(object: qwe.sorted(by: { $0.population > $1.population }), filename: "populationss")
    }
    
    /// Спортивные объекты на карте
    private func makeClusters(hidden: Bool) {
        if (hidden) {
            self.clusterManager.clearItems()
        } else {
            for object in sportObjectResponse.objects {
                let marker: GMSMarker = GMSMarker()
                marker.title = object.title
                marker.snippet = object.department.title
                marker.appearAnimation = .pop // Appearing animation. default
                marker.position = object.coorditate
                self.clusterManager.add(marker)
            }
            self.clusterManager.cluster()
        }
    }
}

extension MapViewController: MapViewInput {

    func setupInitialState() {
        self.title = "Карта"
        self.configureNavigationButtons()
    }

    func response(error: Error) {

    }
}

extension MapViewController: MenuDelegate {

    func didTapShow(detail report: SquareReport) {
        self.output.didTapShow(detail: report)
    }

    func addToDataSource(controller: MapViewDataSource) {
        self.dataSources.append(controller)
    }

    /// Способ выбора границ
    func didSelect(calculated type: CalculateAreaType?) {
        self.calculateAreaType = type
        if let type = type {
            if (type == .borders) {
                self.makeClusters(hidden: true)
                self.makeHeatmap(hidden: true)
                self.makeBorders(hidden: false)
            } else {
                self.murmur(text: "Укажите вручную границы, в пределах которых необходимо произвести расчёт", subtitle: "Точка за точкой", duration: 4.0)
            }
        }
    }

    // Обновление вида карты
    func didUpdate(map type: MenuType) {
        switch type {
        case .clear:
            self.makeClusters(hidden: true)
            self.makeBorders(hidden: true)
            self.makeHeatmap(hidden: true)
        case .heatMap:
            self.makeBorders(hidden: true)
            self.makeHeatmap(hidden: false)
        case .population:
            self.makeHeatmap(hidden: true)
            self.makeBorders(hidden: false)
        case .objects:
            self.makeClusters(hidden: false)
        default: break
        }
    }
}

extension MapViewController: GMSMapViewDelegate {

    /// Движем к кластерам
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.animate(toLocation: marker.position)
        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            return true
        }
        return false
    }

    /// Рисуем границу вручную
    func createArea(with coordinate: CLLocationCoordinate2D) {
        let circ = GMSCircle(position: coordinate, radius: 55.0)
        circ.fillColor = .red
        circ.map = self.mapView

        for p in self.polygons { p.map = nil }
        self.drawPolygon.removeAllCoordinates()
        self.coordinates.append(coordinate)
        for coord in coordinates { self.drawPolygon.add(coord) }
        let polygon = GMSPolygon(path: self.drawPolygon)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.2);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
        self.polygons.append(polygon)
    }

    /// Место (не точные координаты, а координаты места)
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print(name)
        self.createArea(with: location)
    }

    /// Точные координаты на карте
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
        self.createArea(with: coordinate)
    }

    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print(overlay)
        // Dispatch.global {
        if let polygon = overlay as? GMSPolygon, let title = overlay.title {
            //Dispatch.main {
            let populationColor = SharedManager.shared.calculateColor(for: self.lastSelectedPolygon?.title)
            self.lastSelectedPolygon?.fillColor = populationColor
            self.lastSelectedPolygon?.strokeWidth = 3.0

            self.lastSelectedPolygon = polygon
            polygon.fillColor = AppStyle.color(for: .coloured)
            polygon.strokeColor = .black
            polygon.strokeWidth = 5.0
            //  }
            if let population = SharedManager.shared.population(by: title) {
                let report = SharedManager.shared.calculateSportSquare(for: population, polygon: polygon, allPolygons: self.render.mapOverlays() as! [GMSPolygon])
                /// Если нужно для экрана калькуляции
                if let _ = self.calculateAreaType {
                    for dataSource in self.dataSources {
                        // Dispatch.main {
                        dataSource.didCalculated(report: report)
                        // }
                    }
                } else { /// Информация по выбранной границе
                    self.output.didTapShow(detail: report)
                }
            }
            //    }
        }
    }
}
