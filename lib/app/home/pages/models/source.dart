/// 目录下的条目
class SourceItemView {
  final String name;
  final bool isDir;
  final String? ext;
  final int? size; // 如果接口一定返回 null 可保持 int?，否则可以改成 int
  final String modified;
  final String path;
  final String mimeType;

  SourceItemView({
    required this.name,
    required this.isDir,
    this.ext,
    this.size,
    required this.modified,
    required this.path,
    required this.mimeType,
  });

  factory SourceItemView.fromJson(Map<String, dynamic> json) => SourceItemView(
        name: json['name'] as String,
        isDir: json['is_dir'] as bool,
        ext: json['ext'] as String?,
        size: json['size'] as int?,
        modified: json['modified'] as String,
        path: json['path'] as String,
        mimeType: json['mime'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'is_dir': isDir,
        'ext': ext,
        'size': size,
        'modified': modified,
        'path': path,
        'mime': mimeType,
      };
}
