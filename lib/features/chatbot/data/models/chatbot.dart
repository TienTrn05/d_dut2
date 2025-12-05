import 'package:equatable/equatable.dart';

class Chatbot extends Equatable {
  final String id;
  final String name;
  final String jwt;

  const Chatbot({
    required this.id,
    required this.name,
    this.jwt = "",
  });

  Chatbot copyWith({
    String? id,
    String? name,
    String? jwt,
  }) {
    return Chatbot(
      id: id ?? this.id,
      name: name ?? this.name,
      jwt: jwt ?? this.jwt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jwt': jwt,
    };
  }

  @override
  List<Object?> get props => [id, name, jwt];
}
