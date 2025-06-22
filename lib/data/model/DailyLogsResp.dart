import 'dart:convert';

class DailyLogResp {
    bool? status;
    String? message;
    List<DailyLog>? dailyLog;

    DailyLogResp({
        this.status,
        this.message,
        this.dailyLog,
    });

    factory DailyLogResp.fromRawJson(String str) => DailyLogResp.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DailyLogResp.fromJson(Map<String, dynamic> json) => DailyLogResp(
        status: json["status"],
        message: json["message"],
        dailyLog: json["dailyLog"] == null ? [] : List<DailyLog>.from(json["dailyLog"]!.map((x) => DailyLog.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "dailyLog": dailyLog == null ? [] : List<dynamic>.from(dailyLog!.map((x) => x.toJson())),
    };
}

class DailyLog {
    String? id;
    int? howMuch;
    dynamic what;
    String? userId;
    DateTime? createdAt;
    DateTime? updatedAt;

    DailyLog({
        this.id,
        this.howMuch,
        this.what,
        this.userId,
        this.createdAt,
        this.updatedAt,
    });

    factory DailyLog.fromRawJson(String str) => DailyLog.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        id: json["id"],
        howMuch: json["how_much"],
        what: json["what"],
        userId: json["user_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "how_much": howMuch,
        "what": what,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
