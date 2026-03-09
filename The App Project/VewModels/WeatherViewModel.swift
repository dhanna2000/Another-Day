// ViewModels/WeatherViewModel.swift
import Foundation
import WeatherKit
import CoreLocation

@MainActor
class WeatherViewModel: NSObject, ObservableObject {
    @Published var temperature: Measurement<UnitTemperature>?
    @Published var condition: WeatherCondition?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastUpdated: Date?

    private var service: WeatherService?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationStatus = locationManager.authorizationStatus
        
        // Initialize WeatherService
        Task {
            await initializeWeatherService()
        }
    }
    
    private func initializeWeatherService() async {
        do {
            service = try WeatherService()
            print("WeatherViewModel: WeatherService initialized successfully")
        } catch {
            print("WeatherViewModel: Failed to initialize WeatherService: \(error)")
            await MainActor.run {
                self.errorMessage = "Weather service unavailable: \(error.localizedDescription)"
            }
        }
    }

    /// Call this when you need weather (e.g. onTap)
    func requestPermissionAndFetch() {
        print("WeatherViewModel: Requesting location permission...")
        
        // Check current status first
        let currentStatus = locationManager.authorizationStatus
        locationStatus = currentStatus
        
        switch currentStatus {
        case .notDetermined:
            print("WeatherViewModel: Location permission not determined, requesting...")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("WeatherViewModel: Location permission denied/restricted")
            errorMessage = "Location access needed for weather. Please enable in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            print("WeatherViewModel: Location authorized, requesting location...")
            locationManager.requestLocation()
        @unknown default:
            print("WeatherViewModel: Unknown authorization status")
            errorMessage = "Unknown location permission status"
        }
    }
    
    /// Manual refresh function
    func refreshWeather() {
        guard let service = service else {
            errorMessage = "Weather service not available"
            return
        }
        
        if locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            requestPermissionAndFetch()
        }
    }
    
    /// Test WeatherKit connectivity
    func testWeatherKitConnection() async {
        guard let service = service else {
            await MainActor.run {
                errorMessage = "Weather service not available"
            }
            return
        }
        
        // Test with a known location (Apple Park)
        let testLocation = CLLocation(latitude: 37.3346, longitude: -122.0090)
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let weather = try await service.weather(for: testLocation)
            await MainActor.run {
                self.temperature = weather.currentWeather.temperature
                self.condition = weather.currentWeather.condition
                self.errorMessage = "Test successful - WeatherKit is working!"
                self.isLoading = false
                self.lastUpdated = Date()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "WeatherKit test failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    /// Actually do the WeatherKit fetch
    private func fetch(for location: CLLocation) {
        guard let service = service else {
            errorMessage = "Weather service not available"
            isLoading = false
            return
        }
        
        print("WeatherViewModel: Fetching weather for location: \(location)")
        isLoading = true
        Task {
            do {
                let weather = try await service.weather(for: location)
                // update on main actor
                await MainActor.run {
                    self.temperature   = weather.currentWeather.temperature
                    self.condition     = weather.currentWeather.condition
                    self.errorMessage  = nil
                    self.isLoading     = false
                    self.lastUpdated   = Date()
                    print("WeatherViewModel: Successfully fetched weather - Temp: \(weather.currentWeather.temperature), Condition: \(weather.currentWeather.condition)")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Couldn't fetch weather: \(error.localizedDescription)"
                    self.isLoading    = false
                    print("WeatherViewModel: Error fetching weather: \(error)")
                }
            }
        }
    }
}

extension WeatherViewModel: CLLocationManagerDelegate {
    // MARK: – Authorization changed
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        print("WeatherViewModel: Authorization status changed to: \(status.rawValue)")
        
        Task { @MainActor in
            self.locationStatus = status
            
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                print("WeatherViewModel: Location authorized, requesting location...")
                manager.requestLocation()
            } else if status == .denied {
                self.errorMessage = "Location permission denied. Please enable in Settings."
            } else if status == .restricted {
                self.errorMessage = "Location access is restricted."
            }
        }
    }

    // MARK: – Got a location update
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let loc = locations.first else {
            Task { @MainActor in
                self.errorMessage = "Failed to get location."
            }
            return
        }
        print("WeatherViewModel: Got location update: \(loc)")
        // now fetch on main actor
        Task { @MainActor in
            self.fetch(for: loc)
        }
    }

    // MARK: – Location manager error
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("WeatherViewModel: Location manager error: \(error)")
        Task { @MainActor in
            self.errorMessage = "Location error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
