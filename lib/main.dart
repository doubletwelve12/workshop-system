// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:workshop_system/firebase_options.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:go_router/go_router.dart';
import 'package:workshop_system/services/payment_api_service.dart';
import 'package:workshop_system/viewmodels/manage_payroll/pending_payroll_viewmodel.dart';
import 'package:workshop_system/viewmodels/manage_payroll/salary_detail_viewmodel.dart';
import 'package:provider/provider.dart';

// Import your services and repositories
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'services/rating_service.dart'; 
import 'repositories/user_repository.dart';
import 'repositories/foreman_repository.dart';
import 'repositories/workshop_repository.dart';
import 'repositories/payroll_repository.dart'; // Import PayrollRepository
import 'repositories/rating_repository.dart'; // Import RatingRepository
import 'models/app_user_model.dart'; // Import AppUser model
import 'config/router.dart'; // Import the router configuration
import 'data/repositories/schedule_repository.dart';
import 'viewmodels/manage_rating/feedback_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // Service Providers
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        ProxyProvider<FirestoreService, AuthService>(
          update: (context, firestoreService, previousAuthService) =>
              AuthService(firestoreService: firestoreService),
        ),
        Provider<PaymentServiceFactory>(
          create: (_) => PaymentServiceFactory(),
        ), // Correctly close PaymentServiceFactory provider
        Provider<RatingService>(
          create: (_) => RatingService(),
        ),

        // Repository Providers (dependent on services)
        ProxyProvider<FirestoreService, UserRepository>(
          update: (context, firestoreService, previousUserRepository) =>
              UserRepository(firestoreService),
        ),
        ProxyProvider<FirestoreService, ForemanRepository>(
          update: (context, firestoreService, previousForemanRepository) =>
              ForemanRepository(firestoreService),
        ),
        ProxyProvider2<FirestoreService, UserRepository, WorkshopRepository>(
          update: (context, firestoreService, userRepository, previousWorkshopRepository) =>
              WorkshopRepository(firestoreService, userRepository),
        ),
        ProxyProvider<FirestoreService, PayrollRepository>(
          update: (context, firestoreService, previousPayrollRepository) =>
              PayrollRepository(firestoreService),
        ),
        ProxyProvider<FirestoreService, ScheduleRepository>(
          update: (context, firestoreService, previousScheduleRepository) =>
              ScheduleRepository(firestoreService: firestoreService),
        ),
        
        // Rating Repository (depends on AuthService and RatingService)
        ProxyProvider2<AuthService, RatingService, RatingRepository>(
          create: (context) => RatingRepository(
            authService: context.read<AuthService>(),
            ratingService: context.read<RatingService>(),
          ),
          update: (context, authService, ratingService, _) => RatingRepository(
            authService: authService,
            ratingService: ratingService,
          ),
        ),
        
        // ViewModels (depend on repository and services)
        ChangeNotifierProxyProvider2<RatingRepository, AuthService, FeedbackViewModel>(
          create: (context) => FeedbackViewModel(
            ratingRepository: context.read<RatingRepository>(),
            authService: context.read<AuthService>(),
          ),
          update: (context, ratingRepository, authService, _) => FeedbackViewModel(
            ratingRepository: ratingRepository,
            authService: authService,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Workshop Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
