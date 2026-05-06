class DownloaderCategory {
  final String name;
  final String savePath;

  const DownloaderCategory({required this.name, required this.savePath});

  factory DownloaderCategory.fromJson(Map<String, dynamic> json) {
    return DownloaderCategory(
      name: (json['name'] ?? json['category'] ?? '').toString(),
      savePath: (json['savePath'] ?? json['save_path'] ?? '').toString(),
    );
  }
}
