enum AccessRole { viewer, editor, admin }

AccessRole? parseRole(String? role) {
  switch (role) {
    case 'viewer':
      return AccessRole.viewer;
    case 'editor':
      return AccessRole.editor;
    case 'admin':
      return AccessRole.admin;
    default:
      return null;
  }
}
