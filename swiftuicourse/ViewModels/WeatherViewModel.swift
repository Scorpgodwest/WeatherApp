import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var temperature: String = "--"
    @Published var windspeed: String = "--"
    @Published var weatherDescription: String = "Loading..."

    func fetchWeather() {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=51.5072&longitude=-0.1276&current_weather=true"
        guard let url = URL(string: urlString) else { return }

        NetworkManager.shared.fetchData(from: url) { (result: Result<WeatherResponse, Error>) in
            switch result {
            case .success(let weather):
                self.temperature = "\(weather.current_weather.temperature)°C"
                self.windspeed = "\(weather.current_weather.windspeed) km/h"
                self.weatherDescription = self.mapWeatherCode(weather.current_weather.weathercode)
            case .failure:
                self.weatherDescription = "Failed to load"
            }
        }
    }

    private func mapWeatherCode(_ code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Mainly clear, partly cloudy, and overcast"
        case 45, 48: return "Fog and depositing rime fog"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 80, 81, 82: return "Rain showers"
        default: return "Unknown"
        }
    }
} 