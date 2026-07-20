class TransitSchedule {
  final String time;
  final String routeName;
  final String gateName;

  TransitSchedule({
    required this.time,
    required this.routeName,
    required this.gateName,
  });

  factory TransitSchedule.fromJson(Map<String, dynamic> json) {
    return TransitSchedule(
      time: json['time'] as String,
      routeName: json['routeName'] as String,
      gateName: json['gateName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'routeName': routeName,
      'gateName': gateName,
    };
  }
}

class TransitModel {
  final String nextDepartureMinutes;
  final List<TransitSchedule> schedules;

  TransitModel({
    required this.nextDepartureMinutes,
    required this.schedules,
  });

  factory TransitModel.fromJson(Map<String, dynamic> json) {
    final list = json['schedules'] as List? ?? [];
    return TransitModel(
      nextDepartureMinutes: json['nextDepartureMinutes'] as String? ?? '۵',
      schedules: list.map((e) => TransitSchedule.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextDepartureMinutes': nextDepartureMinutes,
      'schedules': schedules.map((e) => e.toJson()).toList(),
    };
  }
}
