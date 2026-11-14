class Person {
  final String id;
  final String name;

  const Person({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Person.fromMap(Map<dynamic, dynamic> map) => Person(
        id: map['id'] as String,
        name: map['name'] as String,
      );

  Person copyWith({String? name}) => Person(id: id, name: name ?? this.name);
}
