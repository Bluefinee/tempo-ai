import Foundation

// MARK: - Date Extensions

extension Date {

    // MARK: - Start/End of Day

    /// 今日の開始時刻（0:00:00）
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// 今日の終了時刻（23:59:59）
    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }

    // MARK: - Date Arithmetic

    /// 指定日数前の日付
    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    /// 指定日数後の日付
    func daysLater(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// 指定時間後の日付
    func hoursLater(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    // MARK: - Time Since Midnight

    /// 深夜0時からの経過分数
    var minutesSinceMidnight: Int {
        let components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    /// 深夜0時からの経過分数（睡眠計算用: 12時以前は+24時間として扱う）
    var minutesSinceMidnightForSleep: Double {
        let components: DateComponents = Calendar.current.dateComponents([.hour, .minute], from: self)
        let hour: Int = components.hour ?? 0
        let minute: Int = components.minute ?? 0

        // 深夜0時以降12時以前は翌日として扱う
        let adjustedHour: Int = hour < 12 ? hour + 24 : hour
        return Double(adjustedHour * 60 + minute)
    }

    // MARK: - Date Comparison

    /// 同じ日かどうか
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// 今日かどうか
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// 昨日かどうか
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    // MARK: - Formatting

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter
    }()

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    /// 時刻のみ表示（例: "23:30"）
    var timeString: String {
        Self.timeFormatter.string(from: self)
    }

    /// 日付のみ表示（例: "1月1日"）
    var dateString: String {
        Self.dateFormatter.string(from: self)
    }

    /// 曜日表示（例: "月"）
    var weekdayString: String {
        Self.weekdayFormatter.string(from: self)
    }

    /// 相対的な日付表示（例: "今日", "昨日", "1月1日"）
    var relativeString: String {
        if isToday {
            return "今日"
        } else if isYesterday {
            return "昨日"
        } else {
            return dateString
        }
    }
}

// MARK: - Date Array Extensions

extension Array where Element == Date {

    /// 標準偏差を計算（秒単位のTimeIntervalで計算）
    var standardDeviation: Double {
        guard count > 1 else { return 0 }

        let intervals: [Double] = map { $0.timeIntervalSinceReferenceDate }
        let mean: Double = intervals.reduce(0, +) / Double(count)
        let squaredDiffs: [Double] = intervals.map { pow($0 - mean, 2) }
        let variance: Double = squaredDiffs.reduce(0, +) / Double(count - 1)

        return sqrt(variance)
    }

    /// 標準偏差を分単位で取得
    var standardDeviationInMinutes: Double {
        standardDeviation / 60
    }
}
