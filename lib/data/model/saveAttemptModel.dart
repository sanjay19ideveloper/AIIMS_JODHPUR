class saveAttemptModel {
  bool? status;
  String? message;
  dynamic data;
  List<String>? errors;

  saveAttemptModel({this.status, this.message, this.data, this.errors});

  saveAttemptModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
    errors = json['errors'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['data'] = this.data;
    data['errors'] = this.errors;
    return data;
  }
}