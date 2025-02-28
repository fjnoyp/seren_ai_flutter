enum AppRoutes {
  signInUp('/signInUp'),
  chooseOrg('/chooseOrg'),
  projects('/projects'),
  projectOverview('/projectOverview'),
  projectDetails('/projectDetails'),
  organization('/organization'),
  manageOrgUsers('/manageOrgUsers'),
  manageTeamUsers('/manageTeamUsers'),
  home('/home'),
  test('/test'),
  tasks('/tasks'),
  taskPage('/taskPage'),
  taskGantt('/taskGantt'),
  aiChats('/aiChats'),
  shifts('/shifts'),
  noteList('/noteList'),
  notePage('/notePage'),
  testSQLPage('/testSQLPage'),
  testAiPage('/testAiPage'),
  termsAndConditions('/termsAndConditions'),
  settings('/settings'),
  resetPassword('/resetPassword'),
  notifications('/notifications'),
  onboarding('/onboarding'),
  noInvites('/noInvites'),
  orgInvite('/orgInvite');

  final String _path;
  const AppRoutes(this._path);

  @override
  String toString() => _path;

  static AppRoutes? getAppRouteFromPath(String path) {
    // Add / if not present
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    // Add trailing / if not present
    if (!path.endsWith('/')) {
      path = '$path/';
    }

    // Remove multiple consecutive slashes and normalize
    path = path.replaceAll(RegExp(r'\/+'), '/');

    for (var route in AppRoutes.values) {
      // Convert route path to pattern by adding trailing slash
      String routePath = route._path;
      if (!routePath.endsWith('/')) {
        routePath = '$routePath/';
      }

      // Check if paths match when normalized
      if (path == routePath) {
        return route;
      }
    }
    return null; // Return null if no match is found
  }
}
