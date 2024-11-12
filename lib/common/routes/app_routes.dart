enum AppRoute {
  signInUp('/signInUp'),
  chooseOrg('/chooseOrg'),
  projects('/projects'),
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
  noteFolderPage('/noteFolderPage'),
  testSQLPage('/testSQLPage'),
  termsAndConditions('/termsAndConditions');

  final String _path;
  const AppRoute(this._path);

  @override
  String toString() => _path;
}