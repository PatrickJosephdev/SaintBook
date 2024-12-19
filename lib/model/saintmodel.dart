class Saint {
  final String name;
  final String story;
  final String imageUrl;
  final String celebrationDate;
  final String videoUrl;

  Saint(
      {required this.name,
      required this.story,
      required this.celebrationDate,
      required this.videoUrl,
      required this.imageUrl});

  factory Saint.fromJson(Map<String, dynamic> json) {
    return Saint(
        name: json['name'],
        story: json['story'],
        celebrationDate: json['celebrationDate'],
        videoUrl: json['videoUrl'],
        imageUrl: json['imageUrl']);
  }
}
