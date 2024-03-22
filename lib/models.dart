class Pokemon {
  final String name;
  final String imageUrl;
  final String type;
  final int number;
  String description;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.number,
    required this.description,
  });
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'] ?? '',
      imageUrl: json['sprites']['front_default'] ?? '',
      type: json['types'][0]['type']['name'] ?? '',
      number: json['id'] ?? 0,
      description: json['description'] ?? '',
    );
  }

 

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
      'number': number,
      'description': description,
    };
  }
}
 // factory Pokemon.fromJson(Map<String, dynamic> json) {
  //   return Pokemon(
  //     name: json['name'],
  //     imageUrl: json['sprites']['front_default'],
  //     type: json['types'][0]['type']['name'],
  //     number: json['id'],
  //     description: json['description'],
  //   );
  // }