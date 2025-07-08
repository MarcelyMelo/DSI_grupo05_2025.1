import 'package:flutter/material.dart';
import 'package:dsi_projeto/components/colors/appColors.dart';

class ExpandableFAB extends StatefulWidget {
  final VoidCallback onCreateFlashcard;
  final VoidCallback onCreateCollection;

  const ExpandableFAB({
    Key? key,
    required this.onCreateFlashcard,
    required this.onCreateCollection,
  }) : super(key: key);

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Overlay to close FAB when tapping outside
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),

        // Expandable options
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Create Collection Button
                Transform.scale(
                  scale: _animation.value,
                  child: Transform.translate(
                    offset: Offset(0, _animation.value * -10),
                    child: Opacity(
                      opacity: _animation.value,
                      child: _buildExpandableButton(
                        icon: Icons.collections_bookmark_outlined,
                        label: 'Criar Coleção',
                        onPressed: () {
                          widget.onCreateCollection();
                          _toggleExpanded();
                        },
                      ),
                    ),
                  ),
                ),

                if (_animation.value > 0) const SizedBox(height: 16),

                // Create Flashcard Button
                Transform.scale(
                  scale: _animation.value,
                  child: Transform.translate(
                    offset: Offset(0, _animation.value * -10),
                    child: Opacity(
                      opacity: _animation.value,
                      child: _buildExpandableButton(
                        icon: Icons.add,
                        label: 'Criar Flashcard',
                        onPressed: () {
                          widget.onCreateFlashcard();
                          _toggleExpanded();
                        },
                      ),
                    ),
                  ),
                ),

                if (_animation.value > 0) const SizedBox(height: 16),

                // Main FAB
                FloatingActionButton(
                  onPressed: _toggleExpanded,
                  backgroundColor: AppColors.blue,
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.125 : 0, // 45 degrees when expanded
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandableButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLogin,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Button
        FloatingActionButton(
          heroTag: label, // Unique hero tag for each button
          onPressed: onPressed,
          backgroundColor: AppColors.blue,
          mini: true,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
