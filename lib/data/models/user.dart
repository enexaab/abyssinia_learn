class AppUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
    };
  }
}
