import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/flashcard.dart';

class FlipCard extends StatefulWidget {
  final String front;
  final String back;
  final bool isKnown;
  final VoidCallback? onStatusToggle;
  final bool showStatusButton;
  final Color? frontColor;
  final Color? backColor;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    this.isKnown = false,
    this.onStatusToggle,
    this.showStatusButton = true,
    this.frontColor,
    this.backColor,
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isShowingFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (!_controller.isAnimating) {
      if (isShowingFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      isShowingFront = !isShowingFront;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingFrontSide = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_animation.value * math.pi),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isShowingFrontSide
                        ? [
                            widget.frontColor?.withOpacity(0.8) ??
                                Colors.blue[400]!,
                            widget.frontColor ?? Colors.blue[600]!
                          ]
                        : widget.isKnown
                            ? [
                                widget.backColor?.withOpacity(0.8) ??
                                    Colors.green[400]!,
                                widget.backColor ?? Colors.green[600]!
                              ]
                            : [
                                widget.backColor?.withOpacity(0.8) ??
                                    Colors.orange[400]!,
                                widget.backColor ?? Colors.orange[600]!
                              ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isShowingFrontSide
                            ? Icons.help_outline
                            : Icons.lightbulb_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      SizedBox(height: 24),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateY(isShowingFrontSide ? 0 : math.pi),
                        child: Text(
                          isShowingFrontSide ? widget.front : widget.back,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24),
                      if (!isShowingFrontSide &&
                          widget.showStatusButton &&
                          widget.onStatusToggle != null) ...[
                        // Status toggle button (only on answer side)
                        ElevatedButton.icon(
                          onPressed: widget.onStatusToggle,
                          icon: Icon(
                            widget.isKnown
                                ? Icons.check_circle
                                : Icons.help_outline,
                            color: Colors.white,
                          ),
                          label: Text(
                            widget.isKnown ? 'Eu sei!' : 'Não sei',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isShowingFrontSide
                              ? 'Toque para ver a resposta'
                              : 'Toque para ver a pergunta',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
