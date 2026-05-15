class ManagedBackgroundImage {
  final String path;
  final String label;
  final String mode;

  const ManagedBackgroundImage({
    required this.path,
    required this.label,
    required this.mode,
  });

  bool get isNetwork => mode == 'network';
  bool get isFile => mode == 'file';
  bool get isAsset => mode == 'asset';
}
