import 'dart:convert';

class LearningContent {
  bool? status;
  String? message;
  List<Datum>? data;
  List<dynamic>? errors;

  LearningContent({this.status, this.message, this.data, this.errors});

  factory LearningContent.fromRawJson(String str) =>
      LearningContent.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LearningContent.fromJson(Map<String, dynamic> json) =>
      LearningContent(
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
  String? learningContentCategoryId;
  String? title;
  String? slug;
  String? content;
  String? image;
  dynamic video;
  Status? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic videoUrl;
  String? imageUrl;

  Datum({
    this.id,
    this.learningContentCategoryId,
    this.title,
    this.slug,
    this.content,
    this.image,
    this.video,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.videoUrl,
    this.imageUrl,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    learningContentCategoryId: json["learning_content_category_id"],
    title: json["title"],
    slug: json["slug"],
    content: json["content"],
    image: json["image"],
    video: json["video"],
    status: statusValues.map[json["status"]]!,
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    videoUrl: json["video_url"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "learning_content_category_id": learningContentCategoryId,
    "title": title,
    "slug": slug,
    "content": content,
    "image": image,
    "video": video,
    "status": statusValues.reverse[status],
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "video_url": videoUrl,
    "image_url": imageUrl,
  };
}

enum Status { PUBLISHED }

final statusValues = EnumValues({"published": Status.PUBLISHED});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
