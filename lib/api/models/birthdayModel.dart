class BirhhdayModel {
  BirhhdayModel({
    required this.id,
    required this.dataset,
    required this.status,
    required this.message,
    required this.code,
    required this.retval,
    required this.totalCount,
    required this.orderId,
  });

  final String? id;
  final Dataset? dataset;
  final int? status;
  final dynamic message;
  final int? code;
  final dynamic retval;
  final dynamic totalCount;
  final dynamic orderId;

  factory BirhhdayModel.fromJson(Map<String, dynamic> json) {
    return BirhhdayModel(
      id: json["\u0024id"],
      dataset: json["dataset"] == null ? null : Dataset.fromJson(json["dataset"]),
      status: json["status"],
      message: json["message"],
      code: json["code"],
      retval: json["retval"],
      totalCount: json["totalCount"],
      orderId: json["orderId"],
    );
  }
}

class Dataset {
  Dataset({required this.id, required this.values});

  final String? id;
  final List<DatasetValue> values;

  factory Dataset.fromJson(Map<String, dynamic> json) {
    return Dataset(
      id: json["\u0024id"],
      values:
          json["\u0024values"] == null
              ? []
              : List<DatasetValue>.from(json["\u0024values"]!.map((x) => DatasetValue.fromJson(x))),
    );
  }
}

class DatasetValue {
  DatasetValue({required this.id, required this.values});

  final String? id;
  final List<ValueValue> values;

  factory DatasetValue.fromJson(Map<String, dynamic> json) {
    return DatasetValue(
      id: json["\u0024id"],
      values:
          json["\u0024values"] == null
              ? []
              : List<ValueValue>.from(json["\u0024values"]!.map((x) => ValueValue.fromJson(x))),
    );
  }
}

class ValueValue {
  ValueValue({
    required this.id,
    required this.dayRemains,
    required this.workLocation,
    required this.designation,
    required this.name,
    required this.day,
  });

  final String? id;
  final String? dayRemains;
  final String? workLocation;
  final String? designation;
  final String? name;
  final String? day;

  factory ValueValue.fromJson(Map<String, dynamic> json) {
    return ValueValue(
      id: json["\u0024id"],
      dayRemains: json["dayRemains"],
      workLocation: json["workLocation"],
      designation: json["designation"],
      name: json["name"],
      day: json["day"],
    );
  }
}
