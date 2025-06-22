import 'dart:convert';

class WeightListResp {
    bool? status;
    String? message;
    List<Weight>? weights;

    WeightListResp({
        this.status,
        this.message,
        this.weights,
    });

    factory WeightListResp.fromRawJson(String str) => WeightListResp.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory WeightListResp.fromJson(Map<String, dynamic> json) => WeightListResp(
        status: json["status"],
        message: json["message"],
        weights: json["weights"] == null ? [] : List<Weight>.from(json["weights"]!.map((x) => Weight.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "weights": weights == null ? [] : List<dynamic>.from(weights!.map((x) => x.toJson())),
    };
}

class Weight {
    String? id;
    String? userId;
    String? weight;
    String? measuredAt;
    MeasuredIn? measuredIn;
    DateTime? createdAt;
    DateTime? updatedAt;

    Weight({
        this.id,
        this.userId,
        this.weight,
        this.measuredAt,
        this.measuredIn,
        this.createdAt,
        this.updatedAt,
    });

    factory Weight.fromRawJson(String str) => Weight.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Weight.fromJson(Map<String, dynamic> json) => Weight(
        id: json["id"],
        userId: json["user_id"],
        weight: json["weight"],
        measuredAt: json["measured_at"],
        measuredIn: measuredInValues.map[json["measured_in"]]!,
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "weight": weight,
        "measured_at": measuredAt,
        "measured_in": measuredInValues.reverse[measuredIn],
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

enum MeasuredIn {
    KG
}

final measuredInValues = EnumValues({
    "kg": MeasuredIn.KG
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
