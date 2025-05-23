enum ReportAccessRole {
  viewer,
  editor,
  admin,
}

ReportAccessRole? parseReportRole(String? role) {
  switch (role) {
    case 'viewer':
      return ReportAccessRole.viewer;
    case 'editor':
      return ReportAccessRole.editor;
    case 'admin':
      return ReportAccessRole.admin;
    default:
      return null;
  }
}

String reportRoleToString(ReportAccessRole role) {
  return role.name; // viewer, editor, admin
}
