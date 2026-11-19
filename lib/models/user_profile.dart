class UserProfile {
  final String name;
  final String email;

  const UserProfile({required this.name, required this.email});

  static const UserProfile defaults = UserProfile(
    name: 'Parking User',
    email: 'user@example.com',
  );
}
