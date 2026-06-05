import '../../features/auth/domain/role.dart';

class Permissions {
  const Permissions(this.role);

  final Role role;

  bool get canSeePaidField => role.isSuperAdmin;
  bool get canSeeUnpaidItems => role.isSuperAdmin;

  bool get canCreateWellOrPipe => role.isSuperAdmin || role.isAdmin;
  bool get canEditWellOrPipe => role.isSuperAdmin || role.isAdmin;
  bool get canDeleteWellOrPipe => role.isSuperAdmin || role.isAdmin;
  bool get canChangePaid => role.isSuperAdmin;

  bool get canManageMasters => role.isSuperAdmin || role.isAdmin;
  bool get canHardDeleteMaster => role.isSuperAdmin;

  bool get canManageUsers => role.isSuperAdmin;
  bool get canViewAuditLog => role.isSuperAdmin;
}
