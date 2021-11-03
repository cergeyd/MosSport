//
//  MapMapViewController.swift
//  MosSportMap
//
//  Created by sergiusX on 15/10/2021.
//  Copyright © 2021 Serjey.com LLC.. All rights reserved.
//

import GoogleMapsUtils
import UIKit

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

class MapViewController: GMClusterViewController {

    struct Config {
        static let initialCoordinates = CLLocationCoordinate2D(latitude: 55.71, longitude: 37.62)
        static let OSMObjectId = 999_999
    }

    var output: MapViewOutput!
    /// Сохраняем последнее значения овердея, чтобы вернуть
    private var lastSelectedPolygon: GMSPolygon?
    /// Контроллеры, которым мы расскажим о наших действах
    private var dataSources: [MapViewDataSource] = []
    /// Если карта, необходима для выбора границ к отчёту
    var calculateAreaType: CalculateAreaType?
    /// Полигон, для рисования вручную
    private var byHandPopulation: Population?
    private var drawPolygon = GMSMutablePath()
    private var polygons: [GMSPolygon] = []
    private var circles: [GMSCircle] = []
    private var coordinates: [CLLocationCoordinate2D] = []
    /// Круги рекомендаций
    private var recommendationsCircles: [GMSCircle] = []
    /// Радиус с доступностью
    private var avaiavailabilityCircle: GMSCircle?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.output.didLoadView()
        /// Вначале были кластеры
        self.makeClusters(hidden: false)
        /// Слушаем обновление, нужны ли дополнительные объекты
        NotificationCenter.default.addObserver(self, selector: #selector(updateSportObjectsList), name: NSNotification.Name.updateSportObjectsList, object: nil)
    }

    //MARK: Private func
    @objc private func updateSportObjectsList() {
        self.makeClusters(hidden: false)
    }

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
}

extension MapViewController: MapViewInput {

    func setupInitialState() {
        self.title = "Карта"
        self.configureNavigationButtons()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.filters"), style: .plain, target: self, action: #selector(didTapShowFilter))
    }
}

//MARK: Виды карт
extension MapViewController {
    /// Тепловая карта спортивных объектов
    private func makeHeatmap(hidden: Bool) {
        if (hidden) { self.heatmapLayer.map = nil; return }
        var list = [GMUWeightedLatLng]()
        for object in gSportObjectResponse.objects { list.append(GMUWeightedLatLng(coordinate: object.coorditate, intensity: 5)) }
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
        if let objects = objects { /// Указаны определённые объекты
            for object in objects {
                let marker = GMSMarker()
                marker.userData = object
                marker.title = object.title
                marker.snippet = object.department.title
                marker.appearAnimation = .pop
                marker.position = object.coorditate
                self.clusterManager.add(marker)
            }
        } else {
            for object in gSportObjectResponse.objects { // Все объекты
                let marker = GMSMarker()
                marker.userData = object
                if (object.id > Config.OSMObjectId) {
                    marker.icon = UIImage(named: "location-pin")
                }
                marker.title = object.title
                marker.snippet = object.department.title
                marker.appearAnimation = .pop
                marker.position = object.coorditate
                if let availabilityType = availabilityType { // Указан определённые тип доступности
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

extension MapViewController: MenuDelegate, DetailViewDelegate, ListViewDelegate {

    func didTapClearBorders() {
        self.clearHandsBorders(isFullClear: true)
    }

    func didTapShowRating() {
        self.output.didTapShowRating()
    }

    /// Указали регион, с экрана 'Рекомендация'
    func didSelect(population: Population, polygon: GMSPolygon) {
        self.mapView.animate(to: GMSCameraPosition(latitude: population.latitude, longitude: population.longitude, zoom: self.mapView.camera.zoom))
        self.didTap(polygon: polygon)
    }

    /// Подготовленная рекомендация по размещению спортивных объектов
    func didCalculate(recommendation: Recommendation) {
        self.makeClusters(hidden: false, availabilityType: recommendation.availabilityType, objects: nil)
        for oldRecommendations in self.recommendationsCircles { oldRecommendations.map = nil }
        for coordinate in recommendation.coordinates {
            let circle = GMSCircle(position: coordinate, radius: 8.0)
            circle.fillColor = AppStyle.color(for: .coloured)
            circle.strokeColor = .black
            circle.strokeWidth = 1.4
            circle.map = self.mapView
            self.recommendationsCircles.append(circle)
        }
    }

    /// Выбираем объект с экрана меню "Департамент" или с экрана "Площадки рядом", движем камеру
    func didSelect(sport object: SportObject) {
        self.mapView.animate(to: GMSCameraPosition(latitude: object.coordinate.latitude, longitude: object.coordinate.longitude, zoom: self.mapView.camera.zoom))
        self.drawAreaCircle(with: object.coorditate, type: object.availabilityType)
    }

    /// Показываем объекты для определённого вида игр
    func didTapShow(type: SportType, objects: [SportObject]) {
        self.output.didTapShow(sportObjects: objects, type: type)
        self.makeClusters(hidden: false, availabilityType: nil, objects: objects)
    }

    /// Отфильтрованный объект спорта
    func didSelect(filter sport: SportObject) {
        self.mapView.animate(to: GMSCameraPosition(latitude: sport.coordinate.latitude, longitude: sport.coordinate.longitude, zoom: self.mapView.camera.zoom))
        self.drawAreaCircle(with: sport.coorditate, type: sport.availabilityType)
        self.output.didTapShow(sport: sport)
    }

    /// Группируем все спортивные. объекты департамента
    func didSelect(department: Department) {
        let sportObjects = SharedManager.shared.objects(for: department)
        self.output.didTapShow(sportObjects: sportObjects, department: department)
    }

    /// Информация по району
    func didSelect(population: Population) {
        self.mapView.animate(to: GMSCameraPosition(latitude: population.latitude, longitude: population.longitude, zoom: 13.0))
        self.makeBorders(hidden: false)
        let allOverlays = self.render.mapOverlays() as! [GMSPolygon]
        for overlay in allOverlays {
            if (overlay.title == population.area) {
                self.mapView(self.mapView, didTap: overlay)
                let report = SharedManager.shared.calculateReport(for: population, polygon: overlay)
                self.output.didTapShow(detail: report)
            }
        }
        self.view.endEditing(true)
    }

    /// Показываем отчёт с экрана калькуляции
    func didTapShow(detail report: SquareReport) {
        self.output.didTapShow(detail: report)
    }

    /// Слушатели
    func addToDataSource(controller: MapViewDataSource) {
        self.dataSources.append(controller)
    }

    /// Способ выбора границ
    func didSelect(calculated type: CalculateAreaType?) {
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
        if (isLoading) { Hud.show() } else { Hud.hide() }
        if (isLoading) { self.navigationController?.navigationBar.start(self.options) } else { self.navigationController?.navigationBar.stop() }
    }
}

//MARK: GMSMapViewDelegate
extension MapViewController {

    /// Движем к кластерам
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.avaiavailabilityCircle?.map = nil
        mapView.animate(toLocation: marker.position)
        if let _ = marker.userData as? GMUCluster { mapView.animate(toZoom: mapView.camera.zoom + 1); return true }
        else {
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
            /// Кружок
            let circle = GMSCircle(position: coordinate, radius: 20.0)
            circle.fillColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            circle.map = self.mapView
            /// По ним строим полигон
            self.circles.append(circle)
            self.coordinates.append(coordinate)
            for coord in self.coordinates { self.drawPolygon.add(coord) }
            /// Полигон
            let polygon = GMSPolygon(path: self.drawPolygon)
            polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.2);
            polygon.strokeColor = .black
            polygon.strokeWidth = 2
            polygon.map = mapView
            self.polygons.append(polygon)

            self.didSelect(point: coordinate)
            if (self.byHandPopulation == nil) { self.population(for: coordinate, in: SharedManager.shared.allPolygons) } /// Район для первой точки.
            self.didTapHandsBorders()
        }
    }

    /// Очистимь ручные границы
    private func clearHandsBorders(isFullClear: Bool = false) {
        if (isFullClear) {
            self.coordinates.removeAll()
            for circle in self.circles { circle.map = nil }
        }
        for polygon in self.polygons { polygon.map = nil }
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
            let report = SharedManager.shared.calculateReport(for: population, path: self.drawPolygon)
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

    /// Подсветим текущий полигон
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
        self.navigationBar(isLoading: true)
        Dispatch.after {
            self.navigationBar(isLoading: false)
            self.avaiavailabilityCircle?.map = nil
            if let polygon = overlay as? GMSPolygon, let title = overlay.title {
                self.didTap(polygon: polygon)
                if let population = SharedManager.shared.population(by: title) {
                    let report = SharedManager.shared.calculateReport(for: population, polygon: polygon)
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
            }
        }
    }
}
