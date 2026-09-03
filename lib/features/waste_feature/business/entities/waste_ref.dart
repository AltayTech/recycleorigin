class WasteRef {
  final int id;
  final String post_title;

  WasteRef({required this.id, required this.post_title});

  factory WasteRef.fromJson(Map<String, dynamic> parsedJson) {
    return WasteRef(id: parsedJson['ID'], post_title: parsedJson['post_title']);
  }

  Map<String, dynamic> toJson() {
    return {'ID': id, 'post_title': post_title};
  }
}
