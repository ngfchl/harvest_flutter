class SubTag {
  final int? id;
  final String name; // 如果业务要求必填，则非空；否则改为 String?
  final String category; // 同上
  final bool available;

  SubTag({
    this.id,
    required this.name,
    required this.category,
    this.available = true,
  });

  factory SubTag.fromJson(Map<String, dynamic> json) {
    return SubTag(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '', // 安全处理 null
      category: json['category'] as String? ?? '', // 或抛异常，根据业务
      available: json['available'] as bool? ?? true,
    );
  }

  SubTag copyWith({
    int? id,
    String? name,
    String? category,
    bool? available,
  }) {
    return SubTag(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      available: available ?? this.available,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'available': available,
    };
  }

  @override
  String toString() {
    return '订阅标签：$name - $category';
  }
}
