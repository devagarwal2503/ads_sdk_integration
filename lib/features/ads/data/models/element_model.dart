import 'package:equatable/equatable.dart';

class ElementModel extends Equatable {
  final String value;
  final String destinationUrl;

  const ElementModel({required this.value, required this.destinationUrl});

  factory ElementModel.fromJson(Map<String, dynamic> json) {
    return ElementModel(
      value: json['value']?.toString() ?? '',
      destinationUrl: json['destination_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'destination_url': destinationUrl};
  }

  @override
  List<Object?> get props => [value, destinationUrl];
}
