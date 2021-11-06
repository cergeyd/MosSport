//
//  CircleInterception.swift
//  MosSportMap
//
//  Created by Sergey D on 06.11.2021.
//

import GoogleMapsUtils

struct CircleEdge {
    let top: CLLocationCoordinate2D
    let left: CLLocationCoordinate2D
    let right: CLLocationCoordinate2D
    let bottom: CLLocationCoordinate2D
}

class CircleInterception {

    static let shared = CircleInterception()
    /// Шаг
    static let step = 0.0001
    static let offset = 5.0
    static private var drawPolygon = GMSMutablePath()
    /// Есть  n окружностей
    /// Знаем центр и радиус
    /// Пересечения - массив координат, на границе окружности, которых входят в другую окружность
    static func interceptions(between circle: GMSCircle, second: GMSCircle) -> [CLLocationCoordinate2D] {
        let firstBorders = self.edgeCoordinates(of: circle)
        let secondBorders = self.edgeCoordinates(of: second)

        let firstPolygon = self.createAvailability(with: firstBorders)
        self.drawPolygon.removeAllCoordinates()
        let secondPolygon = self.createAvailability(with: secondBorders)
        self.drawPolygon.removeAllCoordinates()

        var points: [CLLocationCoordinate2D] = []

        if let path = firstPolygon.path {
            for point in path.allCoordinates {
                if (secondPolygon.contains(coordinate: point)) {
                    points.append(point)
                }
            }
        }
        
        if let path = secondPolygon.path {
            for point in path.allCoordinates {
                if (firstPolygon.contains(coordinate: point)) {
                    points.append(point)
                }
            }
        }
        
        return points
    }

    /// Рисуем границу доступности
    static private func createAvailability(with coordinates: [CLLocationCoordinate2D]) -> GMSPolygon {
        for coord in coordinates { self.drawPolygon.add(coord) }
        let polygon = GMSPolygon(path: self.drawPolygon)
        return polygon
    }

    static private func edgeCoordinates(of circle: GMSCircle) -> [CLLocationCoordinate2D] {
        /// Центр и Радиус
        let center = circle.position
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let radius = circle.radius

        var points: [CLLocationCoordinate2D] = []

        if let circleEdge = self.edges(of: circle) {
            /// Множество точек на границах окружности
            /// Не зря же Apple процессоры улучшает
            /// TOP -> RIGHT
            for i in stride(from: circleEdge.top.longitude, to: circleEdge.right.longitude, by: step) {
                for j in stride(from: circleEdge.right.latitude, to: circleEdge.top.latitude, by: step) {
                    let currentLocation = CLLocation(latitude: j, longitude: i)
                    let distance = currentLocation.distance(from: centerLocation)
                    if (distance > radius - self.offset && distance < radius + self.offset) {
                        points.append(currentLocation.coordinate)
                        break
                    }
                }
            }
            var _points: [CLLocationCoordinate2D] = []
            /// RIGHT -> BOTTOM
            for i in stride(from: circleEdge.bottom.longitude, to: circleEdge.right.longitude, by: step) {
                for j in stride(from: circleEdge.bottom.latitude, to: circleEdge.right.latitude, by: step) {
                    let currentLocation = CLLocation(latitude: j, longitude: i)
                    let distance = currentLocation.distance(from: centerLocation)
                    if (distance > radius - self.offset && distance < radius + self.offset) {
                        _points.append(currentLocation.coordinate)
                        break
                    }
                }
            }
            _points.reverse()
            points.append(contentsOf: _points)
            _points.removeAll()
            /// BOTTOM -> LEFT
            for i in stride(from: circleEdge.left.longitude, to: circleEdge.bottom.longitude, by: step) {
                for j in stride(from: circleEdge.bottom.latitude, to: circleEdge.left.latitude, by: step) {
                    let currentLocation = CLLocation(latitude: j, longitude: i)
                    let distance = currentLocation.distance(from: centerLocation)
                    if (distance > radius - self.offset && distance < radius + self.offset) {
                        _points.append(currentLocation.coordinate)
                        break
                    }
                }
            }
            _points.reverse()
            points.append(contentsOf: _points)
            _points.removeAll()
            /// LEFT -> TOP
            for i in stride(from: circleEdge.left.longitude, to: circleEdge.top.longitude, by: step) {
                for j in stride(from: circleEdge.left.latitude, to: circleEdge.top.latitude, by: step) {
                    let currentLocation = CLLocation(latitude: j, longitude: i)
                    let distance = currentLocation.distance(from: centerLocation)
                    if (distance > radius - self.offset && distance < radius + self.offset) {
                        points.append(currentLocation.coordinate)
                        break
                    }
                }
            }
        }
        return points
    }

    /// Границы окружностей
    static private func edges(of circle: GMSCircle) -> CircleEdge? {
        /// Центр и Радиус
        let center = circle.position
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let radius = circle.radius
        /// Будущие позиция граней окружности
        var top: CLLocationCoordinate2D?
        var bottom: CLLocationCoordinate2D?
        var left: CLLocationCoordinate2D?
        var right: CLLocationCoordinate2D?
        /// TOP
        for i in stride(from: center.latitude, to: center.latitude + 3, by: step) {
            let currentLocation = CLLocation(latitude: i, longitude: center.longitude)
            let distance = currentLocation.distance(from: centerLocation)
            if (distance > radius - self.offset && distance < radius + self.offset) {
                top = currentLocation.coordinate
                break
            }
        }
        /// BOTTOM
        for i in stride(from: center.latitude - 3, to: center.latitude, by: step) {
            let currentLocation = CLLocation(latitude: i, longitude: center.longitude)
            print(currentLocation.coordinate.latitude)
            let distance = currentLocation.distance(from: centerLocation)
            if (distance > radius - self.offset && distance < radius + self.offset) {
                bottom = currentLocation.coordinate
                break
            }
        }
        /// LEFT
        for i in stride(from: center.longitude - 3, to: center.longitude, by: step) {
            let currentLocation = CLLocation(latitude: center.latitude, longitude: i)
            let distance = currentLocation.distance(from: centerLocation)
            if (distance > radius - self.offset && distance < radius + self.offset) {
                left = currentLocation.coordinate
                break
            }
        }
        /// RIGHT
        for i in stride(from: center.longitude, to: center.longitude + 3, by: step) {
            let currentLocation = CLLocation(latitude: center.latitude, longitude: i)
            let distance = currentLocation.distance(from: centerLocation)
            if (distance > radius - self.offset && distance < radius + self.offset) {
                right = currentLocation.coordinate
                break
            }
        }
        if let top = top, let bottom = bottom, let left = left, let right = right {
            return CircleEdge(top: top, left: left, right: right, bottom: bottom)
        }
        return nil
    }
}
