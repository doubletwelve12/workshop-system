import '../models/rating.dart';
import '../services/dummy_rating_service.dart';

class RatingRepository {
  final RatingService _ratingService;

  RatingRepository({required RatingService ratingService})
      : _ratingService = ratingService;

  Future<bool> submitFeedback(Rating rating) async {
    try {
      await _ratingService.saveRatingToFirebase(rating);
      return true;
    } catch (e) {
      print('Error in RatingRepository: $e');
      return false;
    }
  }
}
