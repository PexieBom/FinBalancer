class User {
  final String id;
  final String email;
  final String displayName;

  User({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? json['email'] as String,
    );
  }
}
