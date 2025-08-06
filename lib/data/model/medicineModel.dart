import 'dart:convert';

class MedicineResponse {
  bool? status;
  String? message;
  List<Medication>? medications;
  List<dynamic>? error;

  MedicineResponse({this.status, this.message, this.medications, this.error});

  factory MedicineResponse.fromRawJson(String str) =>
      MedicineResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MedicineResponse.fromJson(Map<String, dynamic> json) =>
      MedicineResponse(
        status: json["status"],
        message: json["message"],
        medications:
            json["medications"] == null
                ? []
                : List<Medication>.from(
                  json["medications"]!.map((x) => Medication.fromJson(x)),
                ),
        error:
            json["error"] == null
                ? []
                : List<dynamic>.from(json["error"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "medications":
        medications == null
            ? []
            : List<dynamic>.from(medications!.map((x) => x.toJson())),
    "error": error == null ? [] : List<dynamic>.from(error!.map((x) => x)),
  };
}

class 

Medication {
  String? id;
  String? userId;
  String? medicineId;
  String? interval;
  String? time;
  List<String>? weekDays;
  dynamic monthDates;
  dynamic yearDates;
  String? startedAt;
  String? endedAt;
  String? medicationTiming;
  String? notes;
  bool? status;
  String? job;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;
  Medicine? medicine;

  Medication({
    this.id,
    this.userId,
    this.medicineId,
    this.interval,
    this.time,
    this.weekDays,
    this.monthDates,
    this.yearDates,
    this.startedAt,
    this.endedAt,
    this.medicationTiming,
    this.notes,
    this.status,
    this.job,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.medicine,
  });

  factory Medication.fromRawJson(String str) =>
      Medication.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json["id"],
    userId: json["user_id"],
    medicineId: json["medicine_id"],
    interval: json["interval"],
    time: json["time"],
    weekDays:
        json["week_days"] == null
            ? []
            : List<String>.from(json["week_days"]!.map((x) => x)),
    monthDates: json["month_dates"],
    yearDates: json["year_dates"],
    startedAt: json["started_at"],
    endedAt: json["ended_at"],
    medicationTiming: json["medication_timing"],
    notes: json["notes"],
    status: json["status"],
    job: json["job"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    deletedAt: json["deleted_at"],
    medicine:
        json["medicine"] == null ? null : Medicine.fromJson(json["medicine"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "medicine_id": medicineId,
    "interval": interval,
    "time": time,
    "week_days":
        weekDays == null ? [] : List<dynamic>.from(weekDays!.map((x) => x)),
    "month_dates": monthDates,
    "year_dates": yearDates,
    "started_at": startedAt,
    "ended_at": endedAt,
    "medication_timing": medicationTiming,
    "notes": notes,
    "status": status,
    "job": job,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "deleted_at": deletedAt,
    "medicine": medicine?.toJson(),
  };
}

class Medicine {
  String? id;
  String? name;
  String? dosage;
  String? description;
  String? manufacturer;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;

  Medicine({
    this.id,
    this.name,
    this.dosage,
    this.description,
    this.manufacturer,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Medicine.fromRawJson(String str) =>
      Medicine.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json["id"],
    name: json["name"],
    dosage: json["dosage"],
    description: json["description"],
    manufacturer: json["manufacturer"],
    status: json["status"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "dosage": dosage,
    "description": description,
    "manufacturer": manufacturer,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
  };
}
