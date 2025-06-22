class AttemptSaveRequest {
  final String? questionId;
  final String? response;
  final String? optionId;

  AttemptSaveRequest({this.questionId, this.response, this.optionId});

  // Add this factory constructor
  factory AttemptSaveRequest.fromJson(Map<String, dynamic> json) {
    return AttemptSaveRequest(
      questionId: json['question_id'],
      response: json['response'],
      optionId: json['option_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['question_id'] = questionId;
    data['response'] = response;
    data['option_id'] = optionId;

    return data;
  }
}
