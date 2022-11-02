import '../../models/terms.dart';

class PredictedLocation {
  final String? id;
  final String? placeId;
  final String? description;
  final List<Term>? terms;
  final List<String>? types;
  PredictedLocation({
    this.id,
    required this.placeId,
    this.description,
    this.terms,
    this.types,
  });

  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'place_id': placeId,
  //     };

  static PredictedLocation formJson(Map<String, dynamic> json) =>
      PredictedLocation(
        id: json['id'],
        placeId: json['place_id'] as String?,
        description: json['description'] as String?,
        terms: json["terms"] != null
            ? json['terms'].map<Term>((json) => Term.fromJson(json)).toList()
            : null,
        types: json['types'] != null
            ? (json['types'] as List<dynamic>).cast<String>()
            : null,
      );
}
