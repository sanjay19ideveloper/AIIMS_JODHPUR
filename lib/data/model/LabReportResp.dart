import 'dart:convert';

class LabReportResponse {
  bool? status;
  String? message;
  List<LabTest>? labTests;

  LabReportResponse({this.status, this.message, this.labTests});

  factory LabReportResponse.fromRawJson(String str) =>
      LabReportResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LabReportResponse.fromJson(Map<String, dynamic> json) =>
      LabReportResponse(
        status: json["status"],
        message: json["message"],
        labTests:
            json["labTests"] == null
                ? []
                : List<LabTest>.from(
                  json["labTests"]!.map((x) => LabTest.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "labTests":
        labTests == null
            ? []
            : List<dynamic>.from(labTests!.map((x) => x.toJson())),
  };
}

class LabTest {
  String? id;
  String? userId;
  String? hemoglobin;
  String? ferritin;
  String? tibc;
  String? isat;
  String? mcv;
  String? mchc;
  String? hsCrp;
  String? ntProBnp;
  String? cholesterol;
  String? hdl;
  String? ldl;
  String? triglycerides;
  String? bloodSugar;
  String? pulseRate;
  String? bloodPressure;
  String? weight;
  String? date;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  LabTest({
    this.id,
    this.userId,
    this.hemoglobin,
    this.ferritin,
    this.tibc,
    this.isat,
    this.mcv,
    this.mchc,
    this.hsCrp,
    this.ntProBnp,
    this.cholesterol,
    this.hdl,
    this.ldl,
    this.triglycerides,
    this.bloodSugar,
    this.pulseRate,
    this.bloodPressure,
    this.weight,
    this.date,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LabTest.fromRawJson(String str) => LabTest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LabTest.fromJson(Map<String, dynamic> json) => LabTest(
    id: json["id"],
    userId: json["user_id"],
    hemoglobin: json["hemoglobin"],
    ferritin: json["ferritin"],
    tibc: json["tibc"],
    isat: json["isat"],
    mcv: json["mcv"],
    mchc: json["mchc"],
    hsCrp: json["hs_crp"],
    ntProBnp: json["nt_pro_bnp"],
    cholesterol: json["cholesterol"],
    hdl: json["hdl"],
    ldl: json["ldl"],
    triglycerides: json["triglycerides"],
    bloodSugar: json["blood_sugar"],
    pulseRate: json["pulse_rate"],
    bloodPressure: json["blood_pressure"],
    weight: json["weight"],
    date: json["date"],
    createdAt: json["created_at"],
    updatedAt:
        json["updated_at"] ,
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "hemoglobin": hemoglobin,
    "ferritin": ferritin,
    "tibc": tibc,
    "isat": isat,
    "mcv": mcv,
    "mchc": mchc,
    "hs_crp": hsCrp,
    "nt_pro_bnp": ntProBnp,
    "cholesterol": cholesterol,
    "hdl": hdl,
    "ldl": ldl,
    "triglycerides": triglycerides,
    "blood_sugar": bloodSugar,
    "pulse_rate": pulseRate,
    "blood_pressure": bloodPressure,
    "weight": weight,
    "date":date,

    "created_at": createdAtValues.reverse[createdAt],
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
  };
}

enum CreatedAt { THE_2_MAY_2025 }

final createdAtValues = EnumValues({"2 May 2025": CreatedAt.THE_2_MAY_2025});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
