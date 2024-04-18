class MetaDataItem {
  final String name;
  final String value;

  MetaDataItem({
    required this.name,
    required this.value,
  });

  factory MetaDataItem.fromJson(Map<String, dynamic> json) {
    return MetaDataItem(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
