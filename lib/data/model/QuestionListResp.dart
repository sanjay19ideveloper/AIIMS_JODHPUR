import 'dart:convert';

class QuestionListResponse {
  Questions? questions;
  bool? status;
  String? message;
  List<dynamic>? errors;

  QuestionListResponse({
    this.questions,
    this.status,
    this.message,
    this.errors,
  });

  factory QuestionListResponse.fromRawJson(String str) =>
      QuestionListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory QuestionListResponse.fromJson(Map<String, dynamic> json) =>
      QuestionListResponse(
        questions:
            json["questions"] == null
                ? null
                : Questions.fromJson(json["questions"]),
        status: json["status"],
        message: json["message"],
        errors:
            json["errors"] == null
                ? []
                : List<dynamic>.from(json["errors"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "questions": questions?.toJson(),
    "status": status,
    "message": message,
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
  };
}

class Questions {
  List<Green>? green;
  List<Green>? yellow;
  List<Green>? red;

  Questions({this.green, this.yellow, this.red});

  factory Questions.fromRawJson(String str) =>
      Questions.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Questions.fromJson(Map<String, dynamic> json) => Questions(
    green:
        json["green"] == null
            ? []
            : List<Green>.from(json["green"]!.map((x) => Green.fromJson(x))),
    yellow:
        json["yellow"] == null
            ? []
            : List<Green>.from(json["yellow"]!.map((x) => Green.fromJson(x))),
    red:
        json["red"] == null
            ? []
            : List<Green>.from(json["red"]!.map((x) => Green.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "green":
        green == null ? [] : List<dynamic>.from(green!.map((x) => x.toJson())),
    "yellow":
        yellow == null
            ? []
            : List<dynamic>.from(yellow!.map((x) => x.toJson())),
    "red": red == null ? [] : List<dynamic>.from(red!.map((x) => x.toJson())),
  };
}

class Green {
  String? id;
  String? question;
  Zone? zone;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic deletedAt;
  List<OptionElement>? options;

  Green({
    this.id,
    this.question,
    this.zone,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.options,
  });

  factory Green.fromRawJson(String str) => Green.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Green.fromJson(Map<String, dynamic> json) => Green(
    id: json["id"],
    question: json["question"],
    zone: zoneValues.map[json["zone"]]!,
    status: json["status"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    deletedAt: json["deleted_at"],
    options:
        json["options"] == null
            ? []
            : List<OptionElement>.from(
              json["options"]!.map((x) => OptionElement.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "zone": zoneValues.reverse[zone],
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "deleted_at": deletedAt,
    "options":
        options == null
            ? []
            : List<dynamic>.from(options!.map((x) => x.toJson())),
  };
}

class OptionElement {
  String? id;
  String? symptomId;
  OptionEnum? option;
  int? isCorrect;
  int? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  OptionElement({
    this.id,
    this.symptomId,
    this.option,
    this.isCorrect,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OptionElement.fromRawJson(String str) =>
      OptionElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OptionElement.fromJson(Map<String, dynamic> json) => OptionElement(
    id: json["id"],
    symptomId: json["symptom_id"],
    option: optionEnumValues.map[json["option"]]!,
    isCorrect: json["is_correct"],
    status: json["status"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "symptom_id": symptomId,
    "option": optionEnumValues.reverse[option],
    "is_correct": isCorrect,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

enum OptionEnum { EMPTY, OPTION }

final optionEnumValues = EnumValues({
  "हाँ": OptionEnum.EMPTY,
  "नहीं": OptionEnum.OPTION,
});

enum Zone { GREEN, RED, YELLOW }

final zoneValues = EnumValues({
  "green": Zone.GREEN,
  "red": Zone.RED,
  "yellow": Zone.YELLOW,
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
