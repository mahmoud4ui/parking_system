import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/reminder_service.dart';
import '../state/profile_controller.dart';
import '../theme/app_theme.dart';
import 'my_bookings_page.dart';
import 'onboarding_page.dart';

class ProfileTab extends StatefulWidget {
  /// Called when the user taps "Saved parking".
  final VoidCallback onOpenSaved;

  const ProfileTab({super.key, required this.onOpenSaved});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ProfileController>();
    _fillFields();
    // The profile loads asynchronously; fill the fields when it arrives.
    // (Done in a listener, not build, so no setState happens during build.)
    _controller.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onProfileChanged);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _fillFields() {
    _nameController.text = _controller.profile.name;
    _emailController.text = _controller.profile.email;
  }

  void _onProfileChanged() {
    // Only overwrite what the user typed when the stored profile differs.
    final profile = _controller.profile;
    if (_nameController.text.trim() != profile.name ||
        _emailController.text.trim() != profile.email) {
      _fillFields();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveProfile() async {
    final error = await _controller.save(
      name: _nameController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    _showMessage(error ?? 'Profile updated successfully.');
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryTeal),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 42,
                backgroundColor: lightTeal,
                child: Icon(Icons.person, size: 46, color: primaryTeal),
              ),
              const SizedBox(height: 14),
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profile.email,
                style: const TextStyle(color: secondaryText, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Personal information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration('Full name', Icons.person_outline),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('Email address', Icons.email_outlined),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save changes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Account settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.bookmark_outline, color: primaryTeal),
          title: const Text('Saved parking'),
          trailing: const Icon(Icons.chevron_right),
          onTap: widget.onOpenSaved,
        ),
        ListTile(
          leading:
              const Icon(Icons.calendar_month_outlined, color: primaryTeal),
          title: const Text('My Bookings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsPage()),
            );
          },
        ),
        // Only visible in debug builds, so it never shows in the live demo.
        if (kDebugMode)
          ListTile(
            leading: const Icon(
              Icons.notifications_active_outlined,
              color: primaryTeal,
            ),
            title: const Text('Test reminders (debug)'),
            subtitle: const Text('Sends one now and one in 10 seconds'),
            onTap: () async {
              final message =
                  await context.read<ReminderService>().sendTestNotifications();
              if (!mounted) return;
              _showMessage(message);
            },
          ),
        ListTile(
          leading: const Icon(Icons.slideshow_outlined, color: primaryTeal),
          title: const Text('View intro'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (pageContext) => OnboardingPage(
                  onFinished: () => Navigator.pop(pageContext),
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline, color: primaryTeal),
          title: const Text('About Parking System'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Parking System',
              applicationVersion: '1.0.0',
            );
          },
        ),
      ],
    );
  }
}
