import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login_screen.dart'; // arahkan ke halaman login kamu

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _isPressed = false;
  late AnimationController _gradientController;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Atur Keuanganmu',
      'subtitle': 'Catat semua pengeluaran dan pemasukan dengan mudah.',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Pantau Pengeluaran',
      'subtitle': 'Lihat laporan dan statistik keuangan harianmu.',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'Capai Tujuanmu',
      'subtitle': 'Rencanakan masa depan finansial yang lebih baik.',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Animasi shimmer gradient looping
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(page['image']!, height: 300),
                        const SizedBox(height: 50),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔵 Indikator halaman
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF3BAA81)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🟩 Tombol interaktif premium
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) {
                  setState(() => _isPressed = false);
                  Future.delayed(const Duration(milliseconds: 120), () {
                    if (_currentIndex == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  });
                },
                onTapCancel: () => setState(() => _isPressed = false),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 150),
                  scale: _isPressed ? 0.94 : 1.0,
                  curve: Curves.easeOut,
                  child: AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, _) {
                      final shimmerValue =
                          (0.5 + 0.5 * _gradientController.value);

                      return Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.lerp(
                                  const Color(0xFF6EE7B7),
                                  const Color(0xFF3BAA81),
                                  shimmerValue)!,
                              Color.lerp(
                                  const Color(0xFF3BAA81),
                                  const Color(0xFF6EE7B7),
                                  shimmerValue)!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(
                                  _isPressed ? 0.15 : 0.25),
                              offset: const Offset(0, 8),
                              blurRadius: _isPressed ? 8 : 18,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentIndex == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedOpacity(
                              opacity:
                                  _currentIndex == _pages.length - 1 ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
