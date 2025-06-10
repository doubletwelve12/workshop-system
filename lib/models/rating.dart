class Rating {
  final String customerName;
  final String jobType;
  final String comment;
  final int stars;

  Rating({
    required this.customerName,
    required this.jobType,
    required this.comment,
    required this.stars,
  });

  // Factory constructor to convert from Firestore/map
  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(
      customerName: map['customerName'] ?? '',
      jobType: map['jobType'] ?? '',
      comment: map['comment'] ?? '',
      stars: map['stars'] ?? 0,
    );
  }

  // To store data in Firebase
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'jobType': jobType,
      'comment': comment,
      'stars': stars,
    };
  }
}
