import 'package:flutter/material.dart';

void main() {
  runApp(const FlowDemoApp());
}

class FlowDemoApp extends StatelessWidget {
  const FlowDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flow Widget',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const FlowDemoScreen(),
    );
  }
}

class FlowDemoScreen extends StatefulWidget {
  const FlowDemoScreen({super.key});

  @override
  State<FlowDemoScreen> createState() => _FlowDemoScreenState();
}

class _FlowDemoScreenState extends State<FlowDemoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _menuAnimation;

  // Icons used as children in the Flow widget
  final List<IconData> _menuIcons = [
    Icons.menu, // Index 0: Primary trigger button
    Icons.mail,
    Icons.call,
    Icons.notifications,
  ];

  @override
  void initState() {
    super.initState();
    _menuAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Widget'),
        backgroundColor: Colors.indigo,
      ),
      body: const SizedBox.shrink(),

      // Sized container to showcase clipping behavior
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
      
        child: Flow(
          // ATTRIBUTE 1: delegate 
          delegate: FlowMenuDelegate(animation: _menuAnimation),

          // ATTRIBUTE 2: clipBehavior
          clipBehavior: Clip.none,

          // ATTRIBUTE 3: children 
          children: _menuIcons.map<Widget>((IconData icon) {
            return FloatingActionButton(
              heroTag: icon.toString(),
              mini: icon != Icons.menu,
              backgroundColor: icon == Icons.menu ? Colors.indigo : Colors.indigoAccent,
              onPressed: () {
                if (icon == Icons.menu) {
                  _menuAnimation.isCompleted
                      ? _menuAnimation.reverse()
                      : _menuAnimation.forward();
                }
              },
              child: Icon(icon, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Custom FlowDelegate
class FlowMenuDelegate extends FlowDelegate {
  FlowMenuDelegate({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    // Paint in reverse order so the toggle button (index 0) remains on top
    for (int i = context.childCount - 1; i >= 0; i--) {
      final double distance = 56.0 * i;
      final double dy = distance * animation.value;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          0.0, // X axis
          -dy, // Y axis (animates upward)
          0.0, // Z axis
        ),
      );
    }
  }

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return animation != oldDelegate.animation;
  }
}