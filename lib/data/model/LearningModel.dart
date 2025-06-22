import 'dart:convert';

class LearningModel {
    bool? status;
    String? message;
    List<LearningData>? data;
    List<dynamic>? errors;

    LearningModel({
        this.status,
        this.message,
        this.data,
        this.errors,
    });

    factory LearningModel.fromRawJson(String str) => LearningModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LearningModel.fromJson(Map<String, dynamic> json) => LearningModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<LearningData>.from(json["data"]!.map((x) => LearningData.fromJson(x))),
        errors: json["errors"] == null ? [] : List<dynamic>.from(json["errors"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x)),
    };
}

class LearningData {
    String? name;
    String? slug;
    String? tagline;
    String? description;
    String? image;
    String? publishedAt;
    String? imageUrl;

    LearningData({
        this.name,
        this.slug,
        this.tagline,
        this.description,
        this.image,
        this.publishedAt,
        this.imageUrl,
    });

    factory LearningData.fromRawJson(String str) => LearningData.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory LearningData.fromJson(Map<String, dynamic> json) => LearningData(
        name: json["name"],
        slug: json["slug"],
        tagline: json["tagline"],
        description: json["description"],
        image: json["image"],
        publishedAt: json["published_at"],
        imageUrl: json["image_url"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "slug": slug,
        "tagline": tagline,
        "description": description,
        "image": image,
        "published_at": publishedAt,
        "image_url": imageUrl,
    };
}
