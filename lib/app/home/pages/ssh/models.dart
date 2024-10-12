class DockerContainer {
  String? id;
  String? image;
  String? name;
  String? status;

  DockerContainer({this.id, this.image, this.name, this.status});

  DockerContainer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    data['status'] = status;
    return data;
  }

  @override
  String toString() {
    return '容器：$name - $id - $image';
  }
}
