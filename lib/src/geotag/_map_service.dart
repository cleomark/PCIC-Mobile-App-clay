// map_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

import '_location_service.dart';

class MapService {
  final MapController mapController = MapController();
  final List<LatLng> routePoints = [];
  double currentZoom = 20.0;
  final List<Marker> markers = [];
  bool _isDisposed = false;
  StreamSubscription<LatLng>? locationSubscription;

  void initLocationService() {
    final locationService = LocationService();
    locationService.requestLocationPermission().then((_) {
      locationSubscription =
          locationService.getLocationStream().listen((location) {
        addMarker(location);
        moveMap(location);
      });
    });
  }

  void addMarker(LatLng point) {
    if (_isDisposed) return;
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    );
    routePoints.add(point);
  }

  void addColoredMarker(LatLng point, Color color) {
    if (_isDisposed) return;
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: point,
        child: Icon(
          Icons.location_on,
          color: color,
          size: 40.0,
        ),
      ),
    );
  }

  void clearMarkers() {
    if (_isDisposed) return;
    markers.clear();
  }

  void removeLastMarker() {
    if (_isDisposed) return;
    if (markers.isNotEmpty) {
      markers.removeLast();
      routePoints.removeLast();
    }
  }

  void addRoutePoint(LatLng point) {
    if (_isDisposed) return;
    routePoints.add(point);
    moveMap(point);
  }

  void clearRoutePoints() {
    if (_isDisposed) return;
    routePoints.clear();
  }

  void moveMap(LatLng point) {
    if (_isDisposed) return;
    mapController.move(point, currentZoom);
  }

  void zoomMap(double zoom) {
    if (_isDisposed) return;
    currentZoom = zoom;
    mapController.move(mapController.center, zoom);
  }

  double calculateZoomLevel(double totalDistance) {
    double zoomLevel = 18.0 - (totalDistance / 10000.0);
    return zoomLevel.clamp(10.0, 20.0);
  }

  LatLng calculateCenterPoint(List<LatLng> points) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    double centerLat = latSum / points.length;
    double centerLng = lngSum / points.length;

    return LatLng(centerLat, centerLng);
  }

  Widget buildMap() {
    return MediaQuery(
      data: const MediaQueryData(),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: const LatLng(13.138769, 123.734005),
          zoom: currentZoom,
          maxZoom: 22.0,
          onPositionChanged: (position, hasGesture) {
            if (_isDisposed) return;
            currentZoom = position.zoom!;
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/quanbysolutions/clvt7is5c00xx01rd3dnthwfr/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoicXVhbmJ5c29sdXRpb25zIiwiYSI6ImNsdWhrejRwdDJyYnAya3A2NHFqbXlsbHEifQ.WJ5Ng-AO-dTrlkUHD_ebMw',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: markers,
          ),
          CurrentLocationLayer(
            alignPositionOnUpdate: AlignOnUpdate.always,
            alignDirectionOnUpdate: AlignOnUpdate.never,
            style: const LocationMarkerStyle(
              marker: DefaultLocationMarker(
                child: Icon(
                  Icons.location_pin,
                  color: Colors.red,
                ),
              ),
              showAccuracyCircle: false,
              showHeadingSector: false,
              markerSize: Size(30, 30),
              markerDirection: MarkerDirection.heading,
            ),
          ),
        ],
      ),
    );
  }

  void dispose() {
    _isDisposed = true;
    locationSubscription?.cancel();
    mapController.dispose();
  }

  double calculateAreaOfPolygon(List<LatLng> points) {
    if (points.length < 3) {
      return 0.0;
    }
    double radius = 6378137.0;
    double area = 0.0;

    for (int i = 0; i < points.length; i++) {
      LatLng p1 = points[i];
      LatLng p2 = points[(i + 1) % points.length];

      double lat1 = p1.latitudeInRad;
      double lon1 = p1.longitudeInRad;
      double lat2 = p2.latitudeInRad;
      double lon2 = p2.longitudeInRad;

      double segmentArea = 2 *
          atan2(
            tan((lon2 - lon1) / 2) * tan((lat1 + lat2) / 2),
            1 + tan(lat1 / 2) * tan(lat2 / 2) * cos(lon1 - lon2),
          );
      area += segmentArea;
    }

    return (area * radius * radius).abs();
  }

  double calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += const Distance().as(
        LengthUnit.Meter,
        points[i],
        points[i + 1],
      );
    }
    return totalDistance;
  }
}
