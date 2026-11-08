class ChatCompletionMessageModel {
  final String content;
  final String role;

  ChatCompletionMessageModel({required this.content, required this.role});

  Map<String, dynamic> toJson() {
    return {"role": role, "content": content};
  }
}
