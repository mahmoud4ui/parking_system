import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _Slide {
  final IconData icon;
  final IconData badgeIcon;
  final String title;
  final String body;
  final String? note;

  const _Slide({
    required this.icon,
    required this.badgeIcon,
    required this.title,
    required this.body,
    this.note,
  });
}

const List<_Slide> _slides = [
  _Slide(
    icon: Icons.map_outlined,
    badgeIcon: Icons.location_on,
    title: 'Find parking in Dubai',
    body: 'Browse garages on the map or in a list, and search by name or '
        'area to find the right spot.',
  ),
  _Slide(
    icon: Icons.event_seat_outlined,
    badgeIcon: Icons.check,
    title: 'See spaces left',
    body: 'Every garage shows how many spaces are still free, so you know '
        'there is room before you set off.',
  ),
  _Slide(
    icon: Icons.notifications_active_outlined,
    badgeIcon: Icons.timer_outlined,
    title: 'Book and stay on time',
    body: 'Reserve a slot, follow the live countdown and get a reminder '
        'before your session ends.',
    note: 'Demo app: listings, prices and availability are samples.',
  ),
];

/// Short intro shown on first launch. [onFinished] is called when the user
/// taps "Get started" or "Skip".
class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingPage({super.key, required this.onFinished});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onFinished();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                child: SizedBox(
                  height: 48,
                  child: _isLast
                      ? null
                      : TextButton(
                          onPressed: widget.onFinished,
                          child: const Text(
                            'Skip',
                            style: TextStyle(color: secondaryText),
                          ),
                        ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) =>
                    _SlideView(slide: _slides[index]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? primaryTeal
                          : primaryTeal.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(_isLast ? 'Get started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: const BoxDecoration(
                      color: lightTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(slide.icon, size: 84, color: primaryTeal),
                  ),
                  Positioned(
                    right: 6,
                    top: 14,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: primaryTeal,
                        shape: BoxShape.circle,
                        border: Border.all(color: pageBackground, width: 4),
                      ),
                      child: Icon(
                        slide.badgeIcon,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              slide.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: secondaryText,
              ),
            ),
            if (slide.note != null) ...[
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  slide.note!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
