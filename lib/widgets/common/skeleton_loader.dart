import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.child,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class SkeletonProjectList extends StatelessWidget {
  const SkeletonProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(width: 120, height: 18, borderRadius: 6),
                  SkeletonLoader(width: 70, height: 20, borderRadius: 8),
                ],
              ),
              SizedBox(height: 12),
              SkeletonLoader(width: double.infinity, height: 14, borderRadius: 4),
              SizedBox(height: 6),
              SkeletonLoader(width: 200, height: 14, borderRadius: 4),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonLoader(width: 80, height: 12, borderRadius: 4),
                  SkeletonLoader(width: 50, height: 12, borderRadius: 4),
                ],
              ),
              SizedBox(height: 8),
              SkeletonLoader(width: double.infinity, height: 8, borderRadius: 4),
            ],
          ),
        );
      },
    );
  }
}

class SkeletonTaskList extends StatelessWidget {
  const SkeletonTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Row(
            children: [
              SkeletonLoader(width: 14, height: 14, borderRadius: 7),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoader(width: 140, height: 14, borderRadius: 4),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        SkeletonLoader(width: 60, height: 16, borderRadius: 6),
                        SizedBox(width: 8),
                        SkeletonLoader(width: 70, height: 16, borderRadius: 8),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonLoader(width: 50, height: 12, borderRadius: 4),
                  SizedBox(height: 4),
                  SkeletonLoader(width: 30, height: 8, borderRadius: 3),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkeletonUserList extends StatelessWidget {
  const SkeletonUserList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: const Row(
            children: [
              SkeletonLoader(width: 40, height: 40, borderRadius: 20),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkeletonLoader(width: 120, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    SkeletonLoader(width: 180, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SkeletonLoader(width: 70, height: 20, borderRadius: 8),
            ],
          ),
        );
      },
    );
  }
}
