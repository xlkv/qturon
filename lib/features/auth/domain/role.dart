enum Role {
  superAdmin('super_admin'),
  admin('admin'),
  user('user');

  const Role(this.wire);

  final String wire;

  static Role fromWire(String? value) {
    return Role.values.firstWhere(
      (r) => r.wire == value,
      orElse: () => Role.user,
    );
  }

  bool get isSuperAdmin => this == Role.superAdmin;
  bool get isAdmin => this == Role.admin;
  bool get isUser => this == Role.user;
}
