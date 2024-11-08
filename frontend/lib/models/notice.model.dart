class Notice {
  final String title;
  final String body;
  final String date;
  final List<String> resources;
  final List<int> categories;
  final int importance;
  final String issuer;
  final String audience;
  final String channelId;

  Notice({
    required this.title,
    required this.body,
    required this.date,
    required this.resources,
    required this.categories,
    required this.importance,
    required this.issuer,
    required this.audience,
    required this.channelId,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      title: json['title'],
      body: json['body'],
      date: json['date'],
      resources: List<String>.from(json['resources']),
      categories: List<int>.from(json['categories']),
      importance: json['importance'],
      issuer: json['issuer'],
      audience: json['audience'],
      channelId: json['channelId'],
    );
  }
}
