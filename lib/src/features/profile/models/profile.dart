class UserProfile {
  final String id;
  final String email;
  final String name;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}

class Subscription {
  final String tier; // free, pro, family
  final List<String> features;
  final DateTime? validUntil;

  Subscription({
    required this.tier,
    required this.features,
    this.validUntil,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      tier: json['tier'],
      features: List<String>.from(json['features'] ?? []),
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
    );
  }
}
