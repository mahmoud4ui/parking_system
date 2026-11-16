import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/storage_service.dart';
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
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _profileName = StorageService.defaultProfile.name;
  String _profileEmail = StorageService.defaultProfile.email;

  @override
  void initState() {
    super.initState();
    _nameController.text = _profileName;
    _emailController.text = _profileEmail;
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.loadProfile();
    if (!mounted) return;

    setState(() {
      _profileName = profile.name;
      _profileEmail = profile.email;
      _nameController.text = profile.name;
      _emailController.text = profile.email;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name.');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    await StorageService.saveProfile(name: name, email: email);
    if (!mounted) return;

    setState(() {
      _profileName = name;
      _profileEmail = email;
    });
    _showMessage('Profile updated successfully.');
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
                _profileName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _profileEmail,
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
                  await NotificationService.sendTestNotifications();
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
