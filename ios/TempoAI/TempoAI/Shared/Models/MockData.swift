import Foundation

#if DEBUG
  struct MockData {

    // MARK: - Time-based Greeting

    static func getCurrentGreeting(nickname: String) -> String {
      let hour: Int = Calendar.current.component(.hour, from: Date())
      let timeOfDay: String

      switch hour {
      case 6..<13:
        timeOfDay = "おはようございます"
      case 13..<18:
        timeOfDay = "こんにちは"
      default:
        timeOfDay = "お疲れさまです"
      }

      return "\(nickname)さん、\(timeOfDay)"
    }

    // MARK: - Weather Mock Data

    static let mockWeather: WeatherInfo = WeatherInfo(
      cityName: "東京",
      temperature: 24,
      weatherIcon: "☀️"
    )

    // MARK: - Date Formatting

    static func getCurrentDateString() -> String {
      let formatter: DateFormatter = DateFormatter()
      formatter.dateFormat = "M月d日 EEEE"
      formatter.locale = Locale(identifier: "ja_JP")
      return formatter.string(from: Date())
    }
  }

  struct WeatherInfo {
    let cityName: String
    let temperature: Int
    let weatherIcon: String
  }
#endif

