class DockerContainer {
  late String id;
  late String image;
  late String name;
  late String status;
  bool hasNew = false;
  ContainerStats? stats;

  DockerContainer(
      {required this.id,
      required this.image,
      required this.name,
      required this.status});

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
    data['stats'] = stats;
    return data;
  }

  @override
  String toString() {
    return '容器：$name - $id - $image';
  }
}

class ContainerStats {
  late String id;
  late String blockIO;
  late String cPUPerc;
  late String memPerc;
  late String memUsage;
  late String netIO;
  late String pIDs;

  ContainerStats(
      {required this.blockIO,
      required this.cPUPerc,
      required this.memPerc,
      required this.memUsage,
      required this.netIO,
      required this.id,
      required this.pIDs});

  ContainerStats.fromJson(Map<String, dynamic> json) {
    blockIO = json['BlockIO'];
    cPUPerc = json['CPUPerc'];
    memPerc = json['MemPerc'];
    memUsage = json['MemUsage'];
    netIO = json['NetIO'];
    pIDs = json['PIDs'];
    id = json['ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BlockIO'] = blockIO;
    data['CPUPerc'] = cPUPerc;
    data['MemPerc'] = memPerc;
    data['MemUsage'] = memUsage;
    data['NetIO'] = netIO;
    data['PIDs'] = pIDs;
    data['ID'] = id;
    return data;
  }
}
