class CommonResponse<T> {
  int code = 0;
  bool succeed = false;
  String msg = '';
  T? data;

  CommonResponse({
    required this.code,
    required this.msg,
    this.data,
    required this.succeed,
  });

  CommonResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    code = json['code'];
    msg = json['msg'];
    succeed = json['succeed'];
    data = fromJsonT(json['data']);
  }

  Map<String, dynamic> toJson(T Function(T) toJsonT) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['succeed'] = this.succeed;
    data['data'] = toJsonT(this.data as T);
    return data;
  }

  CommonResponse.success({
    String? msg,
    this.data,
  }) {
    code = 0;
    succeed = true;
    this.msg = msg ?? '';
  }

  CommonResponse.error({String? msg, this.data}) {
    code = -1;
    succeed = false;
    this.msg = msg ?? '';
  }

  @override
  String toString() {
    return 'Code: $code, Msg: $msg, Succeed: $succeed, Data: $data';
  }
}
