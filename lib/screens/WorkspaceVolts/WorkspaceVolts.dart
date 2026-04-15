import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../../icons/CustomIcons/CustomIcons.dart';
import 'screens/tutorial_screen.dart';
import 'screens/level_select_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const SafetyApp());
}

class SafetyApp extends StatelessWidget {
  const SafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety 8-BIT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'PressStart2P',
      ),
      home: const SafetyMenu(),
    );
  }
}

class SafetyMenu extends StatefulWidget {
  const SafetyMenu({super.key});

  @override
  State<SafetyMenu> createState() => _SafetyMenuState();
}

class _SafetyMenuState extends State<SafetyMenu> with TickerProviderStateMixin {
  final List<_AnimatedLightning> _lightnings = [];
  late Timer _spawnTimer;

  @override
  void initState() {
    super.initState();
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _addLightning();
    });
    // Avvia con 4 fulmini
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 300), _addLightning);
    }
  }

  void _addLightning() {
    final size = Random().nextDouble() * 24 + 12;
    final x = Random().nextDouble() * MediaQuery.of(context).size.width;
    final y = Random().nextDouble() * MediaQuery.of(context).size.height;
    final stayDuration = Duration(milliseconds: Random().nextInt(2000) + 1000);

    const fadeInDuration = Duration(milliseconds: 1000);
    const fadeOutDuration = Duration(milliseconds: 1000);

    final totalDuration = stayDuration + fadeInDuration + fadeOutDuration;

    final controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );

    final fadeInEnd = fadeInDuration.inMilliseconds / totalDuration.inMilliseconds;
    final fadeOutStart = (fadeInDuration + stayDuration).inMilliseconds / totalDuration.inMilliseconds;

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Interval(0.0, fadeInEnd, curve: Curves.easeInOut)),
    );
    final fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller, curve: Interval(fadeOutStart, 1.0, curve: Curves.easeInOut)),
    );

    // Movimento durante il periodo centrale (tra fade-in e fade-out)
    final moveXAnim = Tween<double>(begin: 0.0, end: (Random().nextBool() ? 1 : -1) * 3.0).animate(
      CurvedAnimation(parent: controller, curve: Interval(fadeInEnd, fadeOutStart, curve: Curves.linear)),
    );
    final moveYAnim = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: controller, curve: Interval(fadeInEnd, fadeOutStart, curve: Curves.easeInOut)),
    );

    controller.forward();

    setState(() {
      _lightnings.add(_AnimatedLightning(
        key: UniqueKey(),
        x: x,
        y: y,
        size: size,
        fadeAnim: fadeAnim,
        fadeOutAnim: fadeOutAnim,
        moveXAnim: moveXAnim,
        moveYAnim: moveYAnim,
        controller: controller,
      ));
    });

    fadeOutAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _lightnings.removeWhere((l) => l.key == _lightnings.last.key);
        });
        controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    _spawnTimer.cancel();
    for (var l in _lightnings) {
      l.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      body: Stack(
        children: [
          // Griglia
          CustomPaint(size: screenSize, painter: _GridPainter()),
          
          // Fulmini animati (con fade + oscillazione)
          ..._lightnings.map((l) => Positioned(
                left: l.x + l.moveXAnim.value,
                top: l.y + l.moveYAnim.value,
                child: AnimatedBuilder(
                  animation: l.fadeAnim,
                  builder: (_, _) {
                    return Opacity(
                      opacity: l.fadeAnim.value,
                      child: Icon(
                        Icons.flash_on_outlined,
                        size: l.size,
                        color: const Color(0xFFFF8C42),
                      ),
                    );
                  },
                ),
              )),

          // Menu centrale
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '⚡ SAFETY ⚡',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '8-BIT',
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sicurezza Elettrica\nsul Lavoro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon('assets/images/glove.png'),
                    const SizedBox(width: 16),
                    _buildIcon('assets/images/helmet.png'),
                    const SizedBox(width: 16),
                    _buildIcon('assets/images/firetruck.png'),
                    const SizedBox(width: 16),
                    _buildIcon('assets/images/extinguisher.png'),
                  ],
                ),
                const SizedBox(height: 32),
                _buildButton(
                  color: const Color(0xFFFFD700),
                  icon: CustomIcons.lightning_bolt,
                  label: 'GIOCA',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildButton(
                  color: const Color(0xFF00E676),
                  icon: CustomIcons.book_open,
                  label: 'TUTORIAL',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildButton(color: const Color(0xFF00E5FF), icon: CustomIcons.trophy, label: 'CLASSIFICA'),
                const SizedBox(height: 40),

                Text('100 LIVELLI - MOBILE READY', style: TextStyle(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 4),
                Text('Impara la sicurezza giocando!', style: TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String assetPath) {
      return SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Image.asset(
            assetPath,
            width: 32,
            height: 32,
          ),
        ),
      );
    }

  Widget _buildButton({
    required Color color,
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 300,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 0.4;

    final step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedLightning {
  final Key key;
  final double x, y, size;
  final Animation<double> fadeAnim;
  final Animation<double> fadeOutAnim;
  final Animation<double> moveXAnim;
  final Animation<double> moveYAnim;
  final AnimationController controller;

  _AnimatedLightning({
    required this.key,
    required this.x,
    required this.y,
    required this.size,
    required this.fadeAnim,
    required this.fadeOutAnim,
    required this.moveXAnim,
    required this.moveYAnim,
    required this.controller,
  });
}