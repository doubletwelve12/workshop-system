import 'package:flutter/material.dart';

class RatingStarWidget extends StatefulWidget {
  final int rating;
  final ValueChanged<int>? onRatingSelected;
  final double size;
  final bool isInteractive;

  const RatingStarWidget({
    Key? key,
    required this.rating,
    this.onRatingSelected,
    this.size = 40.0,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  State<RatingStarWidget> createState() => _RatingStarWidgetState();
}

class _RatingStarWidgetState extends State<RatingStarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tapController;
  late List<Animation<double>> _starAnimations;
  late Animation<double> _scaleAnimation;
  
  int _hoverRating = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.elasticOut,
    ));
    
    _starAnimations = List.generate(5, (index) {
      final start = index * 0.1;
      final end = start + 0.3;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.bounceOut),
        ),
      );
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Color _getStarColor(int index) {
    final currentRating = _hoverRating > 0 ? _hoverRating : widget.rating;
    
    if (index < currentRating) {
      // Gradient colors for filled stars
      switch (index) {
        case 0:
          return Colors.red[400]!; // First star - red (poor)
        case 1:
          return Colors.orange[400]!; // Second star - orange (fair)
        case 2:
          return Colors.yellow[600]!; // Third star - yellow (good)
        case 3:
          return Colors.lightGreen[500]!; // Fourth star - light green (very good)
        case 4:
          return Colors.green[500]!; // Fifth star - green (excellent)
        default:
          return Colors.amber;
      }
    }
    return Colors.grey[300]!;
  }

  Widget _buildStar(int index) {
    final isFilled = (_hoverRating > 0 ? _hoverRating : widget.rating) > index;
    final starColor = _getStarColor(index);
    
    return AnimatedBuilder(
      animation: _starAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _starAnimations[index].value,
          child: MouseRegion(
            onEnter: widget.isInteractive ? (_) => _onHover(index + 1) : null,
            onExit: widget.isInteractive ? (_) => _onHoverExit() : null,
            child: GestureDetector(
              onTap: widget.isInteractive ? () => _onStarTap(index + 1) : null,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: (_hoverRating == index + 1 || widget.rating == index + 1) 
                        ? _scaleAnimation.value 
                        : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Stack(
                          children: [
                            // Shadow/glow effect for filled stars
                            if (isFilled)
                              Icon(
                                Icons.star,
                                size: widget.size,
                                color: starColor.withOpacity(0.3),
                              ),
                            // Main star
                            Icon(
                              isFilled ? Icons.star : Icons.star_outline,
                              size: widget.size,
                              color: starColor,
                            ),
                            // Sparkle effect for high ratings
                            if (isFilled && index >= 3)
                              Positioned(
                                top: widget.size * 0.1,
                                right: widget.size * 0.1,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: _starAnimations[index].value,
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: widget.size * 0.3,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onHover(int rating) {
    if (!widget.isInteractive) return;
    setState(() {
      _hoverRating = rating;
    });
  }

  void _onHoverExit() {
    if (!widget.isInteractive) return;
    setState(() {
      _hoverRating = 0;
    });
  }

  void _onStarTap(int selectedRating) {
    if (!widget.isInteractive || widget.onRatingSelected == null) return;
    
    // Add haptic feedback
    // HapticFeedback.lightImpact();
    
    // Trigger tap animation
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    
    widget.onRatingSelected!(selectedRating);
    
    setState(() {
      _hoverRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
            child: _buildStar(index),
          );
        }),
      ),
    );
  }
}