/// Represents a user profile context (guest or authenticated Supabase account).
class Profile {
  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final bool isGuest;
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.isGuest = false,
    required this.createdAt,
  });

  static const String guestProfileId = 'guest';

  static Profile guest() => Profile(
        id: guestProfileId,
        displayName: 'Guest Sanctuary',
        email: null,
        isGuest: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  Profile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isGuest,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
