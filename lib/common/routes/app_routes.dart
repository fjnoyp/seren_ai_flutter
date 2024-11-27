enum AppRoutes {
  signInUp('/signInUp'),
  chooseOrg('/chooseOrg'),
  projects('/projects'),
  projectDetails('/projectDetails'),
  manageOrgUsers('/manageOrgUsers'),
  manageTeamUsers('/manageTeamUsers'),
  home('/home'),
  test('/test'),
  tasks('/tasks'),
  taskPage('/taskPage'),
  aiChats('/aiChats'),
  shifts('/shifts'),
  noteList('/noteList'),
  notePage('/notePage'),
  testSQLPage('/testSQLPage'),
  termsAndConditions('/termsAndConditions');

  final String _path;
  const AppRoutes(this._path);

  @override
  String toString() => _path;

  static AppRoutes? fromString(String path) {
    // Add / if not present
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    for (var route in AppRoutes.values) {
      if (route._path == path) {
        return route;
      }
    }
    return null; // Return null if no match is found
  }
}