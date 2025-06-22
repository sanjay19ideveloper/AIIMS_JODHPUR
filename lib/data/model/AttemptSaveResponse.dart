import 'dart:convert';

class AttemptSaveResponse {
  bool? status;
  String? message;
  List<String>? stepsTaken;
  String? attemptId;
  String? attemptStatus;
  List<dynamic>? errors;

  AttemptSaveResponse({
    this.status,
    this.message,
    this.stepsTaken,
    this.attemptId,
    this.attemptStatus,
    this.errors,
  });

  factory AttemptSaveResponse.fromRawJson(String str) =>
      AttemptSaveResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttemptSaveResponse.fromJson(Map<String, dynamic> json) =>
      AttemptSaveResponse(
        status: json["status"],
        message: json["message"],
        stepsTaken:
            json["steps_taken"] == null
                ? []
                : List<String>.from(json["steps_taken"]!.map((x) => x)),
        attemptId: json["attempt_id"],
        attemptStatus: json["attempt_status"],
        errors:
            json["errors"] == null
                ? []
                : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "steps_taken":
        stepsTaken == null ? [] : List<dynamic>.from(stepsTaken!.map((x) => x)),
    "attempt_id": attemptId,
    "attempt_status": attemptStatus,
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
  };
}
