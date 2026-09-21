class UserData {
  final String uid;
  final String? email;
  final String? displayName;

  const UserData({
    required this.uid,
    this.email,
    this.displayName,
  });
}
