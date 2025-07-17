import 'dart:convert';

DailyLogSaveResponse dailyLogSaveResponseFromJson(String str) => DailyLogSaveResponse.fromJson(json.decode(str));

String dailyLogSaveResponseToJson(DailyLogSaveResponse data) => json.encode(data.toJson());

class DailyLogSaveResponse {
    final bool? status;
    final String? message;
    final String? todayTotal;
    final String? limit;
    final String? liquidIntakeLimitMeasurement;

    DailyLogSaveResponse({
        this.status,
        this.message,
        this.todayTotal,
        this.limit,
        this.liquidIntakeLimitMeasurement,
    });

    factory DailyLogSaveResponse.fromJson(Map<String, dynamic> json) => DailyLogSaveResponse(
        status: json["status"],
        message: json["message"],
        todayTotal: json["today_total"],
        limit: json["limit"],
        liquidIntakeLimitMeasurement: json["liquid_intake_limit_measurement"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "today_total": todayTotal,
        "limit": limit,
        "liquid_intake_limit_measurement": liquidIntakeLimitMeasurement,
    };
}
