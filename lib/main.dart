import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/manage_rating/feedback_view_model.dart';
import 'services/dummy_rating_service.dart';
import 'repositories/rating_repository.dart';
import 'views/manage_rating/user_rating_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Mark constructor as const
  const MyApp({Key? key}) : super(key: key);

  // Move repository inside build or use lazy init, 
  // because const constructors require all fields to be final and initialized at compile-time
  // So better move repository inside build or use a getter.

  @override
  Widget build(BuildContext context) {
    final repository = RatingRepository(
      ratingService: RatingService(),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FeedbackViewModel(
            ratingRepository: repository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Car Workshop Feedback',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: UserRatingScreen(),
      ),
    );
  }
}
