import 'package:flutter/material.dart';

class PremiumFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final Duration delay;

  const PremiumFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.offset = 30.0,
    this.delay = Duration.zero,
  });

  @override
  State<PremiumFadeIn> createState() => _PremiumFadeInState();
}

class _PremiumFadeInState extends State<PremiumFadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _translate = Tween<double>(begin: widget.offset, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translate.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
