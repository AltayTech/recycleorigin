class SocialMedia {
  final String telegram;
  final String instagram;

  SocialMedia({required this.telegram, required this.instagram});

  factory SocialMedia.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return SocialMedia(telegram: '', instagram: '');
    }
    return SocialMedia(
      telegram: raw['telegram'] as String? ?? '',
      instagram: raw['instagram'] as String? ?? '',
    );
  }
}
