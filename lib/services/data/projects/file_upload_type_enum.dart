enum FileUploadType {
  temporary('temporary'), // For files used in a specific operation, not needed afterwards
  document('document'), // For documents that should be preserved
  image('image'), // For image files
  audio('audio'), // For audio recordings
  video('video'), // For video files
  other('other'); // For other file types

  final String _directoryName;
  const FileUploadType(this._directoryName);

  String get directoryName => _directoryName;

  @override
  String toString() => _directoryName;
}
