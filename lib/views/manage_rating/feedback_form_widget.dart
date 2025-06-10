import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manage_rating/feedback_view_model.dart';
import 'rating_star_widget.dart';

class FeedbackFormWidget extends StatefulWidget {
  const FeedbackFormWidget({Key? key}) : super(key: key);

  @override
  State<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends State<FeedbackFormWidget>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late List<Animation<double>> _itemAnimations;
  
  final List<String> jobTypes = [
    'Oil Change',
    'Brake Service',
    'Engine Repair',
    'Tire Service',
    'General Maintenance',
    'Diagnostic',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _itemAnimations = List.generate(4, (index) {
      final start = index * 0.1;
      final end = start + 0.3;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });
    
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedField(Widget child, int index) {
    return AnimatedBuilder(
      animation: _itemAnimations[index],
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _itemAnimations[index].value)),
          child: Opacity(
            opacity: _itemAnimations[index].value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.grey[50],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label + (isRequired ? ' *' : ''),
          prefixIcon: Icon(icon, color: Colors.blue[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildJobTypeSelector(FeedbackViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Service Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: jobTypes.map((jobType) {
            final isSelected = viewModel.jobTypeController.text == jobType;
            return GestureDetector(
              onTap: () {
                setState(() {
                  viewModel.jobTypeController.text = jobType;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  jobType,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection(FeedbackViewModel viewModel) {
    final ratingLabels = [
      'Poor',
      'Fair', 
      'Good',
      'Very Good',
      'Excellent'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star_outline, color: Colors.blue[600], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Rating *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              RatingStarWidget(
                rating: viewModel.ratingStars,
                onRatingSelected: (rating) {
                  setState(() {
                    viewModel.setRating(rating);
                  });
                },
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.ratingStars > 0
                    ? Container(
                        key: ValueKey(viewModel.ratingStars),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          ratingLabels[viewModel.ratingStars - 1],
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name Field
            _buildAnimatedField(
              _buildInputField(
                controller: viewModel.customerNameController,
                label: 'Your Name',
                icon: Icons.person_outline,
                isRequired: true,
              ),
              0,
            ),
            
            const SizedBox(height: 20),
            
            // Job Type Selector
            _buildAnimatedField(
              _buildJobTypeSelector(viewModel),
              1,
            ),
            
            const SizedBox(height: 24),
            
            // Rating Section
            _buildAnimatedField(
              _buildRatingSection(viewModel),
              2,
            ),
            
            const SizedBox(height: 24),
            
            // Comment Field
            _buildAnimatedField(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.message_outlined, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Additional Comments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      color: Colors.grey[50],
                    ),
                    child: TextField(
                      controller: viewModel.commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tell us more about your experience...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              3,
            ),
          ],
        );
      },
    );
  }
}