import 'dart:convert';

class AttemptResponse {
  bool? status;
  String? message;
  List<Datum>? data;
  List<dynamic>? errors;

  AttemptResponse({this.status, this.message, this.data, this.errors});

  factory AttemptResponse.fromRawJson(String str) =>
      AttemptResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttemptResponse.fromJson(Map<String, dynamic> json) =>
      AttemptResponse(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        errors:
            json["errors"] == null
                ? []
                : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
  };
}

class Datum {
  String? id;
  String? userId;
  String? status;
  dynamic notes;
  String? zone;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? steps;

  Datum({
    this.id,
    this.userId,
    this.status,
    this.notes,
    this.zone,
    this.createdAt,
    this.updatedAt,
    this.steps,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    status: json["status"],
    notes: json["notes"],
    zone: json["zone"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    steps:
        json["steps"] == null
            ? []
            : List<String>.from(json["steps"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "status": status,
    "notes": notes,
    "zone": zone,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "steps": steps == null ? [] : List<dynamic>.from(steps!.map((x) => x)),
  };
}
