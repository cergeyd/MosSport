//
//  MapMapViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils
import CoreLocation
import BusyNavigationBar

protocol MapViewDataSource: AnyObject {
    func didCalculated(report: SquareReport)
    func didSelect(border: Detail)
    func didSelect(polygon: GMSPolygon)
}

extension MapViewDataSource {
    func didCalculated(report: SquareReport) { }
    func didSelect(border: Detail) { }
    func didSelect(polygon: GMSPolygon) { }
}

class MapViewController: UIViewController {

    struct Config {
        static let bucketsCount = 100
        static let clusterDistance: UInt = 100
        static let initialCoordinates = CLLocationCoordinate2D(latitude: 55.71, longitude: 37.62)
        static let zoomLevel: Float = 15.0
    }

    var output: MapViewOutput!
    /// Сохраняем последнее значения овердея, чтобы вернуть
    private var lastSelectedPolygon: GMSPolygon?
    /// Контроллеры, которым мы расскажим о наших действах
    private var dataSources: [MapViewDataSource] = []
    /// Если карта, необходима для выбора границ к отчёту
    var calculateAreaType: CalculateAreaType?
    /// Полигон, для рисования вручную
    private var allOverlays: [GMSPolygon] = []
    private var byHandPopulation: Population?
    private var drawPolygon = GMSMutablePath()
    private var polygons: [GMSPolygon] = []
    private var circles: [GMSCircle] = []
    private var coordinates: [CLLocationCoordinate2D] = []
    /// Радиус с доступностью
    private var avaiavailabilityCircle: GMSCircle?
    private var options = BusyNavigationBarOptions()
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
        //_heatmapLayer.radius = 40
        _heatmapLayer.maximumZoomIntensity = 25
        _heatmapLayer.opacity = 0.8
        _heatmapLayer.gradient = GMUGradient(colors: gradientColors, startPoints: gradientStartPoints, colorMapSize: 156)
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
        /// Вначале были кластеры
        self.makeClusters(hidden: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.filters"), style: .plain, target: self, action: #selector(didTapShowFilter))
    }

    //MARK: Private func
    @objc private func didTapShowFilter() {
        let alert = UIAlertController(title: "Спортивные объекты", message: "Доступность", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Все", style: .default, handler: { _ in self.makeClusters(hidden: false, availabilityType: nil) }))
        alert.addAction(UIAlertAction(title: "Шаговая доступность", style: .default, handler: { _ in self.makeClusters(hidden: false, availabilityType: .walking) }))
        alert.addAction(UIAlertAction(title: "Районное", style: .default, handler: { _ in self.makeClusters(hidden: false, availabilityType: .district) }))
        alert.addAction(UIAlertAction(title: "Окружное", style: .default, handler: { _ in self.makeClusters(hidden: false, availabilityType: .area) }))
        alert.addAction(UIAlertAction(title: "Городское", style: .default, handler: { _ in self.makeClusters(hidden: false, availabilityType: .city) }))
        alert.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(alert, animated: true)
    }

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
            list.append(GMUWeightedLatLng(coordinate: object.coorditate, intensity: 5))
        }
        self.heatmapLayer.weightedData = list
        self.heatmapLayer.map = mapView
        self.mapView.animate(to: GMSCameraPosition(latitude: Config.initialCoordinates.latitude, longitude: Config.initialCoordinates.longitude, zoom: 10.0))
    }

    /// Границы Москвы
    private func makeBorders(hidden: Bool) {
        if (hidden) {
            self.render.clear()
        } else {
            let mapOverlays = self.render.mapOverlays() ?? []
            if (mapOverlays.isEmpty) {
                self.render.render()
                for overlay in self.render.mapOverlays() as! [GMSPolygon] {
                    /// Цвет в зависимости от плотности
                    let populationColor = SharedManager.shared.calculateColor(for: overlay.title)
                    overlay.fillColor = populationColor
                    overlay.strokeColor = .black
                    overlay.strokeWidth = 2.5
                }
            }
            SharedManager.shared.allPolygons = self.render.mapOverlays() as! [GMSPolygon]
        }
    }

    /// Спортивные объекты на карте
    private func makeClusters(hidden: Bool, availabilityType: SportObject.AvailabilityType? = nil, objects: [SportObject]? = nil) {
        self.clusterManager.clearItems()
        if let objects = objects {
            for object in objects {
                let marker = GMSMarker()
                marker.userData = object
                marker.title = object.title
                marker.snippet = object.department.title
                marker.appearAnimation = .pop // Appearing animation. default
                marker.position = object.coorditate
                self.clusterManager.add(marker)
            }
        } else {
            for object in sportObjectResponse.objects {
                let marker = GMSMarker()
                marker.userData = object
                marker.title = object.title
                marker.snippet = object.department.title
                marker.appearAnimation = .pop // Appearing animation. default
                marker.position = object.coorditate
                if let availabilityType = availabilityType {
                    if (object.availabilityType == availabilityType) {
                        self.clusterManager.add(marker)
                    }
                } else {
                    self.clusterManager.add(marker)
                }
            }
        }
        self.clusterManager.cluster()
    }
    /// Рисуем радиус доступности (шаговая, городская и т.д.)
    private func drawAreaCircle(with circleCenter: CLLocationCoordinate2D, type: SportObject.AvailabilityType) {
        self.avaiavailabilityCircle?.map = nil
        let circle = GMSCircle(position: circleCenter, radius: SharedManager.shared.meters(for: type))
        circle.fillColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.3589497749)
        circle.strokeColor = .clear
        circle.strokeWidth = 0.0
        circle.map = self.mapView
        self.avaiavailabilityCircle = circle
    }
}

extension MapViewController: MapViewInput {

    func setupInitialState() {
        self.title = "Карта"
        self.configureNavigationButtons()
    }
}

extension MapViewController: MenuDelegate, DetailViewDelegate, ListViewDelegate {

    func didTapClearBorders() {
        self.clearHandsBorders(isFullClear: true)
    }

    /// Указали регион, с экрана 'Рекоммендация'
    func didSelect(population: Population, polygon: GMSPolygon) {
        SharedManager.shared.coordinates(by: population) { coordinates in
            if let coordinates = coordinates {
                self.mapView.animate(to: GMSCameraPosition(latitude: coordinates.latitude, longitude: coordinates.longitude, zoom: self.mapView.camera.zoom))
            }
        }
        self.didTap(polygon: polygon)
    }

    /// Подготовленная рекомендация по размещению спортивных объектов
    func didCalculate(recommendation: Recommendation) {
        for coordinate in recommendation.coordinates {
            let circle = GMSCircle(position: coordinate, radius: 4)
            circle.fillColor = .black
            circle.strokeColor = .black
            circle.strokeWidth = 1.0
            circle.map = self.mapView
        }
    }

    /// Выбираем объект с экрна меню "Департамент" или с экрана "Площадки рядом", движем камеру
    func didSelect(sport object: SportObject) {
        self.mapView.animate(to: GMSCameraPosition(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude, zoom: self.mapView.camera.zoom))
    }

    func didTapShow(type: SportType, objects: [SportObject]) {
        self.output.didTapShow(sportObjects: objects, type: type)
        self.makeClusters(hidden: false, availabilityType: nil, objects: objects)
    }

    /// Отфильтрованный объект спорта
    func didSelect(filter sport: SportObject) {
        self.mapView.animate(to: GMSCameraPosition(latitude: sport.coordinate.latitude, longitude: sport.coordinate.longitude, zoom: self.mapView.camera.zoom))
        self.output.didTapShow(sport: sport)
    }

    /// Группируем все спортивные. объекты департамента
    func didSelect(department: Department) {
        let sportObjects = SharedManager.shared.objects(for: department)
        self.output.didTapShow(sportObjects: sportObjects, department: department)
    }

    /// Информация по району
    func didSelect(population: Population) {
        /// Координаты районов лень добавлять, пока вот так
        SharedManager.shared.coordinates(by: population) { coordinates in
            if let coordinates = coordinates {
                self.mapView.animate(to: GMSCameraPosition(latitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 13.0))
            } else {
                self.murmur(text: "Координаты не определены", isError: true, subtitle: "")
            }
        }
        self.makeBorders(hidden: false)
        let allOverlays = self.render.mapOverlays() as! [GMSPolygon]
        for overlay in allOverlays {
            if (overlay.title == population.area) {
                self.mapView(self.mapView, didTap: overlay)
                let report = SharedManager.shared.calculateSportSquare(for: population, polygon: overlay)
                self.output.didTapShow(detail: report)
            }
        }
        self.view.endEditing(true)
    }

    /// Показываем отчёт с экрана калькуляции
    func didTapShow(detail report: SquareReport) {
        self.output.didTapShow(detail: report)
    }

    func addToDataSource(controller: MapViewDataSource) {
        self.dataSources.append(controller)
    }

    /// Способ выбора границ
    func didSelect(calculated type: CalculateAreaType?) {
        // lastSelectedAreaReport = nil
        self.calculateAreaType = type
        self.makeHeatmap(hidden: true)
        if let type = type {
            if (type == .borders || type == .recommendation) {
                self.makeBorders(hidden: false)
                self.clearHandsBorders(isFullClear: true)
            } else {
                self.makeBorders(hidden: true)
                self.murmur(text: "Укажите вручную границы, в пределах которых необходимо произвести расчёт", subtitle: "Точка за точкой", duration: 4.0)
            }
        }
    }

    /// Обновление вида карты
    func didUpdate(map type: MenuType) {
        self.navigationBar(isLoading: true)
        switch type {
        case .clear:
            Dispatch.after { self.navigationBar(isLoading: false) }
            self.avaiavailabilityCircle?.map = nil
            self.makeClusters(hidden: true)
            self.makeBorders(hidden: true)
            self.makeHeatmap(hidden: true)
        case .heatMap:
            Dispatch.after(5.0) { Dispatch.after { self.navigationBar(isLoading: false) } }
            self.makeBorders(hidden: true)
            self.makeHeatmap(hidden: false)
        case .population:
            Dispatch.after { self.navigationBar(isLoading: false) }
            self.makeHeatmap(hidden: true)
            self.makeBorders(hidden: false)
        case .objects:
            Dispatch.after { self.navigationBar(isLoading: false) }
            self.makeClusters(hidden: false)
        default: break
        }
    }

    func navigationBar(isLoading: Bool) {
        if (isLoading) {
            self.navigationController?.navigationBar.start(self.options)
        } else {
            self.navigationController?.navigationBar.stop()
        }
    }
}

extension MapViewController: GMSMapViewDelegate {

    /// Движем к кластерам
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.avaiavailabilityCircle?.map = nil
        mapView.animate(toLocation: marker.position)
        if let _ = marker.userData as? GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            return true
        } else {
            if let object = marker.userData as? SportObject {
                self.drawAreaCircle(with: object.coorditate, type: object.availabilityType)
                self.output.didTapShow(sport: object)
            }
        }
        return false
    }

    /// Рисуем границу вручную
    func createArea(with coordinate: CLLocationCoordinate2D) {
        /// Если нужно для экрана калькуляции
        if let _ = self.calculateAreaType {
            self.clearHandsBorders()

            let circle = GMSCircle(position: coordinate, radius: 25.0)
            circle.fillColor = #colorLiteral(red: 0.8302407265, green: 0.6964268088, blue: 0.4022175074, alpha: 1)
            circle.map = self.mapView

            self.circles.append(circle)
            self.coordinates.append(coordinate)
            for coord in self.coordinates { self.drawPolygon.add(coord) }

            let polygon = GMSPolygon(path: self.drawPolygon)
            polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.2);
            polygon.strokeColor = .black
            polygon.strokeWidth = 2
            polygon.map = mapView
            self.polygons.append(polygon)

            self.didSelect(point: coordinate)
            if (self.byHandPopulation == nil) {
                self.population(for: coordinate, in: self.allOverlays)
            }
            self.didTapHandsBorders()
        }
    }

    private func clearHandsBorders(isFullClear: Bool = false) {
        if (isFullClear) {
            self.coordinates.removeAll()
            for c in self.circles { c.map = nil }
        }
        for p in self.polygons { p.map = nil }
        self.drawPolygon.removeAllCoordinates()
    }

    /// Расскажем, пользователь поставил точку
    private func didSelect(point coordinate: CLLocationCoordinate2D) {
        self.navigationBar(isLoading: true)
        SharedManager.shared.address(for: coordinate) { address in
            let detail = Detail(type: .square, title: address?.street ?? "Улица не определена", place: address?.city ?? "", subtitle: "")
            for dataSource in self.dataSources {
                dataSource.didSelect(border: detail)
            }
            self.navigationBar(isLoading: false)
        }
    }

    /// Ручные границы приняты
    @objc private func didTapHandsBorders() {
        if let population = self.byHandPopulation {
            let report = SharedManager.shared.calculateSportSquare(for: population, path: self.drawPolygon)
            for dataSource in self.dataSources {
                dataSource.didCalculated(report: report)
            }
        }
    }

    /// Определим район по первой точке ручного ввода
    private func population(for coordinate: CLLocationCoordinate2D, in polygons: [GMSPolygon]) {
        for polygon in polygons {
            if (polygon.contains(coordinate: coordinate)) {
                let population = SharedManager.shared.population(by: polygon.title)
                self.byHandPopulation = population
            }
        }
    }

    /// Место (не точные координаты, а координаты места)
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        self.avaiavailabilityCircle?.map = nil
        self.createArea(with: location)
    }

    /// Точные координаты на карте
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.avaiavailabilityCircle?.map = nil
        self.createArea(with: coordinate)
    }
    
    private func didTap(polygon: GMSPolygon) {
        let populationColor = SharedManager.shared.calculateColor(for: self.lastSelectedPolygon?.title)
        self.lastSelectedPolygon?.fillColor = populationColor
        self.lastSelectedPolygon?.strokeWidth = 3.0
        self.lastSelectedPolygon = polygon
        polygon.fillColor = AppStyle.color(for: .coloured).withAlphaComponent(0.1)
        polygon.strokeColor = .black
        polygon.strokeWidth = 5.0
    }

    /// Выбираем регион
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        self.avaiavailabilityCircle?.map = nil
        print(overlay)
        if let polygon = overlay as? GMSPolygon, let title = overlay.title {
            self.didTap(polygon: polygon)
            if let population = SharedManager.shared.population(by: title) {
                let report = SharedManager.shared.calculateSportSquare(for: population, polygon: polygon)
                /// Если нужно для экрана калькуляции
                if let type = self.calculateAreaType {
                    if (type == .recommendation) {
                        for dataSource in self.dataSources {
                            dataSource.didSelect(polygon: polygon)
                        }
                    } else {
                        for dataSource in self.dataSources {
                            dataSource.didCalculated(report: report)
                        }
                    }
                } else { /// Информация по выбранной границе
                    self.output.didTapShow(detail: report)
                }
            }
            self.calc(overlay: polygon)
        }
    }

    private func calc(overlay: GMSPolygon) {
//        print(overlay.path!.allCoordinates.count)
//        // 56.026179 36.827946 | 55.169184 37.962116
//        var minLeft: Double = 500.0 // 37.5115
//        var topLeft: Double = 0.0 // 55.6899
//
//        var maxRight: Double = 0.0 // 37.5555
//        var bottomRight: Double = 500.0 //55.66819
//
//        for coordinate in overlay.path!.allCoordinates {
//            let latitude = coordinate.latitude
//            let longitude = coordinate.longitude
//
//            if (longitude < minLeft) {
//                minLeft = longitude
//            }
//            if (latitude > topLeft) {
//                topLeft = latitude
//            }
//
//            if (longitude > maxRight) {
//                maxRight = longitude
//            }
//            if (latitude < bottomRight) {
//                bottomRight = latitude
//            }
//        }
//
//        let left = CLLocationCoordinate2D(latitude: topLeft, longitude: minLeft)
//        let right = CLLocationCoordinate2D(latitude: bottomRight, longitude: maxRight)
//
//        let circle = GMSCircle(position: left, radius: 100)
//        circle.fillColor = .red
//        circle.strokeColor = .black
//        circle.strokeWidth = 10.0
//        circle.map = self.mapView
//
//        let circle1 = GMSCircle(position: right, radius: 100)
//        circle1.fillColor = .red
//        circle1.strokeColor = .black
//        circle1.strokeWidth = 10.0
//        circle1.map = self.mapView
//
//        var points: [CLLocationCoordinate2D] = []
//
//        let objects = SharedManager.shared.objects(for: overlay)
//
//        for i in stride(from: minLeft, to: maxRight, by: 0.003) {
//            for j in stride(from: bottomRight, to: topLeft, by: 0.001) {
//                let current = CLLocationCoordinate2D(latitude: j, longitude: i)
//                if (overlay.contains(coordinate: current)) {
//                    points.append(current)
//                    print(current)
//                    let circle = GMSCircle(position: current, radius: 12)
//                    circle.fillColor = .black
//                    circle.strokeColor = .black
//                    circle.strokeWidth = 1.0
//                    circle.map = self.mapView
//                }
//            }
//        }
//        print(points.count)
    }
}
