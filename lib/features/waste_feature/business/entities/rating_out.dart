/// One submitted rating as returned by the collect API.
class RatingOut {
  const RatingOut({
    required this.score,
    this.comment = '',
    this.createdAt = '',
    this.raterRole = '',
  });

  final int score;
  final String comment;
  final String createdAt;
  final String raterRole;

  factory RatingOut.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RatingOut(score: 0);
    }
    final s = json['score'];
    return RatingOut(
      score: s is int ? s : int.tryParse('$s') ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      raterRole: json['rater_role'] as String? ?? '',
    );
  }
}

double? parseAverageRating(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
