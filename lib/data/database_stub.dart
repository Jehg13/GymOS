class GymDatabase {
  GymDatabase._();

  static final GymDatabase instance = GymDatabase._();

  Future<void> initialize() async {}

  final Map<String, Map<String, Object?>> _users =
      <String, Map<String, Object?>>{};
  final Map<String, List<Map<String, dynamic>>> _collections =
      <String, List<Map<String, dynamic>>>{};

  Future<Map<String, Object?>?> findUser(String email) async => _users[email];

  Future<void> createUser({
    required String name,
    required String email,
    required String passwordHash,
  }) async {
    _users[email] = {
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Future<void> updatePassword(String email, String passwordHash) async {
    final user = _users[email];
    if (user != null) user['password_hash'] = passwordHash;
  }

  Future<List<Map<String, dynamic>>> readCollection(String key) async =>
      _collections[key]
          ?.map((value) => Map<String, dynamic>.from(value))
          .toList() ??
      [];

  Future<void> writeCollection(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    _collections[key] = values
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }
}
