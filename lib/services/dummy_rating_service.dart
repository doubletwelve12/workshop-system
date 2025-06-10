import '../models/rating.dart';

class RatingService {
  final List<Rating> _dummyDatabase = [];

/*************  ✨ Windsurf Command ⭐  *************/
  /// Simulates saving a rating to a Firebase Realtime Database. This is a dummy
  /// implementation for testing and development purposes only. It does not
  /// actually write to a Firebase Realtime Database. Instead, it adds the rating
  /// to a local in-memory list and prints a message to the console. This
  /// function is asynchronous and returns a Future that resolves after a 1
  /// second delay.
/*******  5f8c18b4-3875-461a-9054-2d27d6e5d801  *******/  Future<void> saveRatingToFirebase(Rating rating) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    _dummyDatabase.add(rating);
    print("Saved rating to dummy DB: ${rating.toMap()}");
  }

  List<Rating> getAllRatings() => _dummyDatabase;
}
