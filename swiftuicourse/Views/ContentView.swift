import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var isNight: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        ZStack {
            BackgroundView(isNight: isNight)
            VStack {
                CityTextView(cityName: "London")
                    .foregroundColor(.white)
                    .padding()
                MainWeatherStatusView(
                    imageName: mapWeatherCodeToSymbol(viewModel.weatherCode, isNight: isNight),
                    temperature: viewModel.temperatureInt
                )
                .padding(.bottom, 40)
                HStack(spacing: 20) {
                    WeatherDayView(dayOfWeek: "TUE",
                                   imageName: "cloud.sun.fill",
                                   temperature: 74)
                    WeatherDayView(dayOfWeek: "WED",
                                   imageName: "sun.max.fill",
                                   temperature: 88)
                    WeatherDayView(dayOfWeek: "THU",
                                   imageName: "wind.snow",
                                   temperature: 55)
                    WeatherDayView(dayOfWeek: "FRI",
                                   imageName: "sunset.fill",
                                   temperature: 60)
                    WeatherDayView(dayOfWeek: "SAT",
                                   imageName: "snow",
                                   temperature: 25)
                }
                Spacer()
                Text(viewModel.weatherDescription)
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Wind: \(viewModel.windspeed)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Button {
                    isNight.toggle()
                } label: {
                    WeatherButton(title: "Change Day Time", textColor: .mint, backgroundColor: .white)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchWeather()
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                viewModel.fetchWeather()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    func mapWeatherCodeToSymbol(_ code: Int, isNight: Bool) -> String {
        switch code {
        case 0: return isNight ? "moon.stars.fill" : "sun.max.fill"
        case 1, 2, 3: return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        default: return "questionmark"
        }
    }
}

extension WeatherViewModel {
    var temperatureInt: Int {
        Int(Double(temperature.replacingOccurrences(of: "°C", with: "")) ?? 0)
    }
    var weatherCode: Int {
        if let code = (Mirror(reflecting: self).children.first { $0.label == "_current_weather" }?.value as? CurrentWeather)?.weathercode {
            return code
        }
        return 0
    }
}

#Preview {
    ContentView()
}

struct WeatherDayView: View {
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    var body: some View {
        
        VStack {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Image(systemName: imageName)
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temperature)")
                .font(.system(size: 27, weight: .bold, design: .default))
                .foregroundColor(.white)
        }
    }
}

struct BackgroundView: View {
    
    var isNight: Bool
    
    var body: some View {
//        LinearGradient(colors: [isNight ? .black : .blue, isNight ? .white : Color("lightblue")], startPoint: .topLeading, endPoint: .bottomTrailing)
//            .ignoresSafeArea()
        ContainerRelativeShape()
            .fill(isNight ? Color.black.gradient : Color.blue.gradient)
            .ignoresSafeArea()
    }
}

struct CityTextView: View {
    var cityName: String
    var body: some View {
        Text(cityName)
            .font(.system(size: 32,
                          weight: .medium,
                          design: .default))
            .foregroundColor(.white)
            .padding()
    }
}

struct MainWeatherStatusView: View {
    var imageName: String
    var temperature: Int
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            Text("\(temperature)°")
                .font(.system(size: 80, weight: .bold, design: .default))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
}

