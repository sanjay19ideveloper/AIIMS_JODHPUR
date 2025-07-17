import 'dart:convert';

class ZoneSaveResponse {
  bool? status;
  String? message;
  Data? data;
  List<dynamic>? errors;
  List<String>? stepsToBeTaken;

  ZoneSaveResponse({
    this.status,
    this.message,
    this.data,
    this.errors,
    this.stepsToBeTaken,
  });

  factory ZoneSaveResponse.fromRawJson(String str) =>
      ZoneSaveResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ZoneSaveResponse.fromJson(Map<String, dynamic> json) =>
      ZoneSaveResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        errors: json["errors"] == null
            ? []
            : List<dynamic>.from(json["errors"].map((x) => x)),
        stepsToBeTaken: json["steps_to_be_taken"] == null
            ? []
            : List<String>.from(json["steps_to_be_taken"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "errors": errors == null
            ? []
            : List<dynamic>.from(errors!.map((x) => x)),
        "steps_to_be_taken": stepsToBeTaken == null
            ? []
            : List<String>.from(stepsToBeTaken!.map((x) => x)),
      };
}

class Data {
  String? userId;
  String? zone;
  String? id;
  String? updatedAt;
  String? createdAt;

  Data({
    this.userId,
    this.zone,
    this.id,
    this.updatedAt,
    this.createdAt,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        zone: json["zone"],
        id: json["id"],
        updatedAt: json["updated_at"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "zone": zone,
        "id": id,
        "updated_at": updatedAt,
        "created_at": createdAt,
      };
}
