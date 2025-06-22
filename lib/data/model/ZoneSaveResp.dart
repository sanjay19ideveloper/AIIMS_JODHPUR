import 'dart:convert';

class ZoneSaveResponse {
    bool? status;
    String? message;
    Data? data;
    List<dynamic>? errors;

    ZoneSaveResponse({
        this.status,
        this.message,
        this.data,
        this.errors,
    });

    factory ZoneSaveResponse.fromRawJson(String str) => ZoneSaveResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ZoneSaveResponse.fromJson(Map<String, dynamic> json) => ZoneSaveResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        errors: json["errors"] == null ? [] : List<dynamic>.from(json["errors"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
        "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
    };
}

class Data {
    String? userId;
    String? zone;
    String? id;
    DateTime? updatedAt;
    DateTime? createdAt;

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
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "zone": zone,
        "id": id,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
    };
}
