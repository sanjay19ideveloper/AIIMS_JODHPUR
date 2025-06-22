class SymptomModel {
  Questions? questions;
  bool? status;
  String? message;
  List<String>? errors;

  SymptomModel({this.questions, this.status, this.message, this.errors});

  SymptomModel.fromJson(Map<String, dynamic> json) {
    questions = json['questions'] != null
        ? new Questions.fromJson(json['questions'])
        : null;
    status = json['status'];
    message = json['message'];
    errors = json['errors'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.questions != null) {
      data['questions'] = this.questions!.toJson();
    }
    data['status'] = this.status;
    data['message'] = this.message;
    data['errors'] = this.errors;
    return data;
  }
}

class Questions {
  List<Green>? green;
  List<Yellow>? yellow;
  List<Red>? red;

  Questions({this.green, this.yellow, this.red});

  Questions.fromJson(Map<String, dynamic> json) {
    if (json['green'] != null) {
      green = <Green>[];
      json['green'].forEach((v) {
        green!.add(new Green.fromJson(v));
      });
    }
    if (json['yellow'] != null) {
      yellow = <Yellow>[];
      json['yellow'].forEach((v) {
        yellow!.add(new Yellow.fromJson(v));
      });
    }
    if (json['red'] != null) {
      red = <Red>[];
      json['red'].forEach((v) {
        red!.add(new Red.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.green != null) {
      data['green'] = this.green!.map((v) => v.toJson()).toList();
    }
    if (this.yellow != null) {
      data['yellow'] = this.yellow!.map((v) => v.toJson()).toList();
    }
    if (this.red != null) {
      data['red'] = this.red!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Green {
  String? id;
  String? question;
  List<String>? options;
  String? answer;
  String? zone;
  int? status;
  String? createdAt;
  String? updatedAt;

  Green(
      {this.id,
        this.question,
        this.options,
        this.answer,
        this.zone,
        this.status,
        this.createdAt,
        this.updatedAt});

  Green.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    options = json['options'].cast<String>();
    answer = json['answer'];
    zone = json['zone'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['options'] = this.options;
    data['answer'] = this.answer;
    data['zone'] = this.zone;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Yellow {
  String? id;
  String? question;
  List<String>? options;
  String? answer;
  String? zone;
  int? status;
  String? createdAt;
  String? updatedAt;

  Yellow(
      {this.id,
        this.question,
        this.options,
        this.answer,
        this.zone,
        this.status,
        this.createdAt,
        this.updatedAt});

  Yellow.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    options = json['options'].cast<String>();
    answer = json['answer'];
    zone = json['zone'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['options'] = this.options;
    data['answer'] = this.answer;
    data['zone'] = this.zone;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Red {
  String? id;
  String? question;
  List<String>? options;
  String? answer;
  String? zone;
  int? status;
  String? createdAt;
  String? updatedAt;

  Red(
      {this.id,
        this.question,
        this.options,
        this.answer,
        this.zone,
        this.status,
        this.createdAt,
        this.updatedAt});

  Red.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    options = json['options'].cast<String>();
    answer = json['answer'];
    zone = json['zone'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question'] = this.question;
    data['options'] = this.options;
    data['answer'] = this.answer;
    data['zone'] = this.zone;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}