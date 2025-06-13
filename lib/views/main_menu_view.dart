import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:workshop_system/viewmodels/main_menu_viewmodel.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainMenuViewModel(
        authService: Provider.of<AuthService>(context, listen: false),
        userRepository: Provider.of<UserRepository>(context, listen: false),
      ),
      child: Consumer<MainMenuViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Main Menu'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await viewModel.logout();
                    // After logout, navigate to the welcome/login screen
                    context.go('/welcome'); // Assuming '/welcome' is your initial auth route
                  },
                ),
              ],
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null
                    ? Center(child: Text('Error: ${viewModel.errorMessage}'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome, ${viewModel.currentUser?.name ?? 'User'}!',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Role: ${viewModel.currentUser?.role ?? 'N/A'}',
                              style: Theme.of(context).textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32.0),
                            _buildMenuItem(
                              context,
                              'My Profile',
                              () => viewModel.navigateToUserProfile(context),
                            ),
                            const SizedBox(height: 16.0),
                            if (viewModel.isForeman) ...[
                              _buildMenuItem(
                                context,
                                'Available Now',
                                () => context.push('/workshops/available'),
                              ),
                              const SizedBox(height: 16.0),
                              _buildMenuItem(
                                context,
                                'My Applications',
                                () => context.push('/foreman/applications/pending'),
                              ),
                              const SizedBox(height: 16.0),
                              _buildMenuItem(
                                context,
                                'Search Workshops',
                                () => viewModel.navigateToWorkshopSearch(context),
                              ),
                              const SizedBox(height: 16.0),
                              // Customer Rating Section
                              _buildMenuItem(
                                context,
                                'Customer Rating',
                                () => context.push('/customer-rating'),
                              ),
                              const SizedBox(height: 16.0),
                              // View My Ratings Section
                              _buildMenuItem(
                                context,
                                'My Ratings',
                                () => context.push('/my-ratings'),
                              ),
                            ],
                            if (viewModel.isWorkshopOwner) ...[
                              _buildMenuItem(
                                context,
                                'Foreman Requests',
                                () => context.push('/workshop/foremen/requests'),
                              ),
                              const SizedBox(height: 16.0),
                              _buildMenuItem(
                                context,
                                'My Approved Foremen',
                                () => context.push('/workshop/foremen/whitelisted'),
                              ),
                              const SizedBox(height: 16.0),
                              _buildMenuItem(
                                context,
                                'Manage Workshop Schedule',
                                () => context.push('/workshop/schedule/manage'),
                              ),
                              const SizedBox(height: 16.0), // Add spacing
                              _buildMenuItem(
                                context,
                                'Manage Payroll', // Button text
                                () => context.push('/pending-payroll'), // Navigation action
                              ),
                              const SizedBox(height: 16.0),
                              // Workshop Owner can view all ratings for their workshop
                              _buildMenuItem(
                                context,
                                'All Workshop Ratings',
                                () => context.push('/all-ratings'),
                              ),
                            ],
                            const SizedBox(height: 16.0),
                            _buildMenuItem(
                                context, 
                                'Manage Schedule Demo', 
                                () => context.push('/demo')
                            )
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18.0),
      ),
    );
  }
}
