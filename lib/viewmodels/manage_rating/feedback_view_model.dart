import 'package:flutter/material.dart';
import '../../models/rating.dart';
import '../../repositories/rating_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  // Use RatingRepository instead of RatingController
  final RatingRepository ratingRepository;

  final customerNameController = TextEditingController();
  final jobTypeController = TextEditingController();
  final commentController = TextEditingController();

  int _ratingStars = 0;
  bool _isSubmitting = false;
  String _submissionStatus = '';

  // Constructor now requires RatingRepository
  FeedbackViewModel({required this.ratingRepository});

  int get ratingStars => _ratingStars;
  bool get isSubmitting => _isSubmitting;
  String get submissionStatus => _submissionStatus;

  void setRating(int value) {
    _ratingStars = value;
    notifyListeners();
  }

  Future<bool> submitRating() async {
    final name = customerNameController.text.trim();
    final job = jobTypeController.text.trim();
    final comment = commentController.text.trim();

    if (name.isEmpty || _ratingStars == 0) return false;

    final feedback = Rating(
      customerName: name,
      jobType: job,
      comment: comment,
      stars: _ratingStars,
    );

    _isSubmitting = true;
    _submissionStatus = '';
    notifyListeners();

    // Use the repository to submit the feedback
    final result = await ratingRepository.submitFeedback(feedback);

    _isSubmitting = false;
    _submissionStatus = result ? 'success' : 'error';
    notifyListeners();

    return result;
  }

  @override
  void dispose() {
    customerNameController.dispose();
    jobTypeController.dispose();
    commentController.dispose();
    super.dispose();
  }
  
  // Add this property
  bool _showValidationErrors = false;

  // Add this getter
  bool get showValidationErrors => _showValidationErrors;

  // Add this method
  void setShowValidationErrors(bool value) {
    _showValidationErrors = value;
    notifyListeners();
  }
  
}
