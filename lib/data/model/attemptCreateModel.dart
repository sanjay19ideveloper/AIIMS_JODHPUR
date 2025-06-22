import 'dart:convert';

class AttemptCreateResponse {
  bool? status;
  String? message;
  Data? data;
  List<dynamic>? errors;

  AttemptCreateResponse({this.status, this.message, this.data, this.errors});

  factory AttemptCreateResponse.fromRawJson(String str) =>
      AttemptCreateResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttemptCreateResponse.fromJson(Map<String, dynamic> json) =>
      AttemptCreateResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        errors:
            json["errors"] == null
                ? []
                : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
  };
}

class Data {
  String? id;
  String? userId;
  bool? status;
  dynamic notes;
  dynamic zone;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<dynamic>? responses;
  dynamic options;

  Data({
    this.id,
    this.userId,
    this.status,
    this.notes,
    this.zone,
    this.createdAt,
    this.updatedAt,
    this.responses,
    this.options,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    userId: json["user_id"],
    status: json["status"],
    notes: json["notes"],
    zone: json["zone"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    responses:
        json["responses"] == null
            ? []
            : List<dynamic>.from(json["responses"]!.map((x) => x)),
    options: json["options"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "status": status,
    "notes": notes,
    "zone": zone,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "responses":
        responses == null ? [] : List<dynamic>.from(responses!.map((x) => x)),
    "options": options,
  };
}
