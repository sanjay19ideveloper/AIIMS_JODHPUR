class WeightModel {
  bool? status;
  String? message;
  List<Weights>? weights;

  WeightModel({this.status, this.message, this.weights});

  WeightModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['weights'] != null) {
      weights = <Weights>[];
      json['weights'].forEach((v) {
        weights!.add(new Weights.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.weights != null) {
      data['weights'] = this.weights!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Weights {
  String? id;
  String? userId;
  String? weight;
  String? measuredAt;
  String? measuredIn;
  String? createdAt;
  String? updatedAt;

  Weights(
      {this.id,
        this.userId,
        this.weight,
        this.measuredAt,
        this.measuredIn,
        this.createdAt,
        this.updatedAt});

  Weights.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    weight = json['weight'];
    measuredAt = json['measured_at'];
    measuredIn = json['measured_in'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['weight'] = this.weight;
    data['measured_at'] = this.measuredAt;
    data['measured_in'] = this.measuredIn;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}