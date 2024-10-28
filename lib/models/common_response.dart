class CommonResponse<T> {
  int? code = 0;
  String? msg = '';
  T? data;

  CommonResponse({this.code, this.msg, this.data});

  CommonResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    code = json['code'];
    msg = json['msg'];
    data = fromJsonT(json['data']);
  }

  Map<String, dynamic> toJson(T Function(T) toJsonT) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['data'] = toJsonT(this.data as T);
    return data;
  }

  CommonResponse.success({
    String? msg,
    this.data,
  }) {
    code = 0;
    this.msg = msg ?? '';
  }

  CommonResponse.error({String? msg}) {
    code = -1;
    this.msg = msg ?? '';
    data = null;
  }

  @override
  String toString() {
    return 'Code: $code, Msg: $msg, Data: $data';
  }
}
