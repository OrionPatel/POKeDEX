import 'dart:convert';
import 'dart:math';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:pokedex_v3/models.dart';

Future<Pokemon> fetchPokemon(String pokemonUrl) async {
  try {
    Dio dio = Dio();

    dio.options.baseUrl = 'https://pokeapi.co/api/v2';
    dio.options.queryParameters = {'limit': 10};
    dio.options.validateStatus = (status) => true; // Allow all status codes
    dio.interceptors.add(LogInterceptor(
        responseBody: true)); // Add this line to see the response log
    // Disable SSL verification
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    final response = await dio.get(pokemonUrl);
    if (response.statusCode == 200) {
      final String name = response.data['name'];
      final String imageUrl = response.data['sprites']['front_default'];
      final String type = response.data['types'][0]['type']['name'];
      final int number = response.data['id'];
      final speciesUrl = response.data['species']['url'];

      // Fetch species data
      final speciesResponse = await dio.get(speciesUrl);
      if (speciesResponse.statusCode == 200) {
        // Extract description from species data
        final descriptions = speciesResponse.data['flavor_text_entries'];
        final description = descriptions.firstWhere(
            (entry) => entry['language']['name'] == 'en')['flavor_text'];
        Pokemon pokemon = Pokemon(
          name: name,
          imageUrl: imageUrl,
          type: type,
          number: number,
          description: description,
        );
        return pokemon;
      } else {
        throw Exception('Failed to fetch Pokémon species');
      }
    } else {
      throw Exception('Failed to fetch Pokémon');
    }
  } catch (e) {
    throw Exception('Error fetching Pokémon: $e');
  }
}

Future<void> getPokemonByType(String Type) async {
  try {
    Dio dio = Dio();

    dio.options.baseUrl = 'https://pokeapi.co/api/v2';
    dio.options.queryParameters = {'limit': 10};
    dio.options.validateStatus = (status) => true;
    dio.interceptors.add(LogInterceptor(responseBody: true));
    // Disable SSL verification
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    final response = await dio.get('https://pokeapi.co/api/v2/type/$Type');

    print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonData = response.data;
      List<dynamic> pokemonList = jsonData['pokemon'];

      print('saving in the respective type list');

      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/${Type}list.json');
      await file.writeAsString(jsonEncode(pokemonList));
    } else {
      throw Exception('failed to fetch ${Type}type pokemon');
    }
  } catch (e) {
    throw Exception('error: $e');
  }
}

Future<List<Map<String, dynamic>>> getpokeList(String type) async {
  try {
    Dio dio = Dio();

    dio.options.baseUrl = 'https://pokeapi.co/api/v2';
    dio.options.queryParameters = {'limit': 10};
    dio.options.validateStatus = (status) => true;
    dio.interceptors.add(LogInterceptor(responseBody: true));
    // Disable SSL verification
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    final response = await dio.get('https://pokeapi.co/api/v2/type/$type');

    print(response.statusCode);

    if (response.statusCode == 200) {
      final jsonData = response.data;
      List<dynamic> pokemonList = jsonData['pokemon'];

      List<Map<String, dynamic>> pokeList =
          pokemonList.cast<Map<String, dynamic>>();
      return pokeList;
      // final directory = await getApplicationCacheDirectory();
      // final file = File('${directory.path}/${type}list.json');
      // await file.writeAsString(jsonEncode(pokemonList));
    } else {
      throw Exception('error in returning pokeList ');
    }
  } catch (e) {
    throw Exception('erorr: $e');
  }
}

Future<void> saveList(String type, List<Map<String, dynamic>> pokelist) async {
  final directory = await getApplicationCacheDirectory();
  final file = File('${directory.path}/${type}list.json');
  final List<dynamic> pokeList = pokelist;
  final String jsonString = jsonEncode(pokeList);
  await file.writeAsString(jsonString);
}

Future<List<Map<String, dynamic>>> loadPokeList(String type) async {
  final directory = await getApplicationCacheDirectory();
  final file = File('${directory.path}/${type}list.json');
  final jsonString = await file.readAsString();
  List<dynamic> _pokeList = jsonDecode(jsonString);

  List<Map<String, dynamic>> pokeList = _pokeList.cast<Map<String, dynamic>>();
  print('$type list loaded');
  return pokeList;
}



Future<Pokemon> getPokemon(String url) async {
  try {
    final dio = Dio();
    final response = await Dio().get(url);

    if (response.statusCode == 200) {
      Pokemon _pokemon = Pokemon.fromJson(response.data);
      final descriptionResponse =
          await dio.get(response.data['species']['url']);
      if (descriptionResponse.statusCode == 200) {
        final Map<String, dynamic> speciesData = descriptionResponse.data;
        final String description =
            speciesData['flavor_text_entries'][0]['flavor_text'];
        _pokemon.description = description;
      }
      return _pokemon;
    } else {
      throw Exception('Failed to load Pokemon details');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<void> savePokemon(Pokemon pokemon) async {
  final String jsonString = jsonEncode(pokemon.toJson());
  final directory = await getApplicationCacheDirectory();
  final folder = Directory('${directory.path}/pokemon');
  // Create the directory if it doesn't exist
  if (!folder.existsSync()) {
    print('created the folder');
    folder.createSync(recursive: true);
  }
  final file = File('${folder.path}/${pokemon.name}.json');
  await file.writeAsString(jsonString);
  print('saved the pokemon');
}

Future<Pokemon?> loadPokemon(String pokemonName) async {
  final directory = await getApplicationCacheDirectory();
  final filePath = '${directory.path}/pokemon/$pokemonName.json';
  final file = File(filePath);
  
  if (await file.exists()) {
    // Read the JSON data from the file
    String jsonString = await file.readAsString();
    // Decode the JSON data into a Map
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    // Create a Pokemon object from the decoded JSON
    Pokemon pokemon = Pokemon(
      name: jsonMap['name'],
      imageUrl: jsonMap['imageUrl'],
      type: jsonMap['type'],
      number: jsonMap['number'],
      description: jsonMap['description'],
    );
    return pokemon;
  } else {
    // File doesn't exist, return null or handle the case as needed
    return null;
  }
}
