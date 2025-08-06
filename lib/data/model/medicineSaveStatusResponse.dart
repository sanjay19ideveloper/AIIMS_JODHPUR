// To parse this JSON data, do
//
//     final medicineSaveStatusResp = medicineSaveStatusRespFromJson(jsonString);

import 'dart:convert';

MedicineSaveStatusResp medicineSaveStatusRespFromJson(String str) => MedicineSaveStatusResp.fromJson(json.decode(str));

String medicineSaveStatusRespToJson(MedicineSaveStatusResp data) => json.encode(data.toJson());

class MedicineSaveStatusResp {
    final bool? status;
    final String? message;
    final MedicationLog? medicationLog;

    MedicineSaveStatusResp({
        this.status,
        this.message,
        this.medicationLog,
    });

    factory MedicineSaveStatusResp.fromJson(Map<String, dynamic> json) => MedicineSaveStatusResp(
        status: json["status"],
        message: json["message"],
        medicationLog: json["medicationLog"] == null ? null : MedicationLog.fromJson(json["medicationLog"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "medicationLog": medicationLog?.toJson(),
    };
}

class MedicationLog {
    final String? medicationId;
    final String? status;
    final String? userId;
    final String? id;
    final DateTime? updatedAt;
    final DateTime? createdAt;

    MedicationLog({
        this.medicationId,
        this.status,
        this.userId,
        this.id,
        this.updatedAt,
        this.createdAt,
    });

    factory MedicationLog.fromJson(Map<String, dynamic> json) => MedicationLog(
        medicationId: json["medication_id"],
        status: json["status"],
        userId: json["user_id"],
        id: json["id"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "medication_id": medicationId,
        "status": status,
        "user_id": userId,
        "id": id,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
    };
}
