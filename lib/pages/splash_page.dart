// lib/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_screen.dart';
import '/widgets/gradient_background.dart';

class SplashPage extends StatelessWidget {
  static const routeName = 'splash-page';
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const MainScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: const Logo(),
          ),
        ),
      ),
    );
  }
}

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String assetPath = 'assets/images/Logo_F2_2.png';

    final Size screenSize = MediaQuery.of(context).size;
    final double shortestSide = screenSize.shortestSide;

    final bool isTablet = screenSize.shortestSide >= 600;
    final bool isSmallPhone = shortestSide < 380;

    double imageSize;
    if (isTablet) {
      imageSize = screenSize.width * 0.65;
    } else if (isSmallPhone) {
      imageSize = 280;
    } else {
      imageSize = 330;
    }

    // Adjust font sizes
    final double titleFontSize = isTablet ? 24 : (isSmallPhone ? 13 : 15);
    final double hintFontSize = isTablet ? 18 : (isSmallPhone ? 12 : 14);
    final double iconSize = isTablet ? 50 : (isSmallPhone ? 28 : 35);

    final double textTranslateOffset = isTablet
        ? -45
        : (isSmallPhone ? -25 : -30);
    final double bottomPadding = isTablet ? 120 : (isSmallPhone ? 40 : 60);

    return Stack(
      children: [
        // (Logo + Text)
        Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Image.asset(
                    assetPath,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                ),
                Transform.translate(
                  offset: Offset(0, textTranslateOffset),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Developing STEM Skills Through Exploration',
                      style: GoogleFonts.alice(
                        textStyle: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // (Icon + "Touch to start")
        Positioned(
          bottom: isTablet ? 70 : 50,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.touch_app,
                  size: iconSize,
                  color: Color(0xFFFFA600),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Touch to start',
                style: GoogleFonts.alice(
                  textStyle: TextStyle(
                    fontSize: hintFontSize,
                    color: Color.fromARGB(136, 0, 0, 0),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
