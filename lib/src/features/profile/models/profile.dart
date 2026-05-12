class UserProfile {
  final String id;
  final String email;
  final String name;
  final int householdSize;
  final List<String> dietaryRestrictions;
  final List<String> allergies;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool twoFactorEnabled;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.householdSize,
    required this.dietaryRestrictions,
    required this.allergies,
    this.avatarUrl,
    required this.isEmailVerified,
    required this.twoFactorEnabled,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString().trim();
    return UserProfile(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: (name != null && name.isNotEmpty) ? name : json['email']?.toString() ?? 'User',
      householdSize: (json['household_size'] as num?)?.toInt() ?? 1,
      dietaryRestrictions:
          List<String>.from(json['dietary_restrictions'] as List? ?? const []),
      allergies: List<String>.from(json['allergies'] as List? ?? const []),
      avatarUrl: json['avatar_url']?.toString(),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
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
