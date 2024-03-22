import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_v3/models.dart';

import 'service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

List<Map<String, dynamic>> fireList = [];
List<Map<String, dynamic>> grassList = [];
List<Map<String, dynamic>> iceList = [];
List<Map<String, dynamic>> allList = [];
List<Map<String, dynamic>> searchList = [];
List<Map<String, dynamic>> currentList = [];

class _HomeScreenState extends State<HomeScreen> {
  double containerHeight = 200;
  double _elevation1 = 2;
  double _floatinglocationtop = 250;
  double floatingButtonWidth = 120;
  double floatingButttonHeight = 80;

  void filterToggleSize() {
    setState(() {
      // var currentType = type;

      if (floatingButtonWidth == 120) {
        floatingButtonWidth = 180;

        _elevation1 = 6;
      } else {
        floatingButtonWidth = 120;

        _elevation1 = 2;
      }
    });
  }

  Future<void> _initialize() async {
    List<String> types = ['fire', 'grass', 'ice'];
    for (var type in types) {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/${type}list.json');
      if (await file.exists()) {
        print('$type file exists and can be loaded');
      }

      // loadPokeList(type);
    }
    fireList = await loadPokeList('fire');
    grassList = await loadPokeList('grass');
    iceList = await loadPokeList('ice');
    allList = iceList + fireList + grassList;
    setState(() {
      currentList = allList;
    });
  }

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
  }

  void searchPokemon(String searchText) {
    // Clear previous search results
    searchList.clear();
    // Iterate through allList to find matches
    for (var pokemon in allList) {
      String pokemonName = pokemon['pokemon']['name'].toString().toLowerCase();
      if (pokemonName.contains(searchText.toLowerCase())) {
        searchList.add(pokemon);
      }
    }
    // Update UI with search results
    setState(() {
      currentList = searchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(
              "assets/background.png",
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(0, 0, 0, 0).withOpacity(0)),
                  child: const Center(
                    child: Text(
                      'POKEDEX',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 40),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(20),
                      color:
                          const Color.fromARGB(198, 0, 11, 49).withOpacity(0),
                    ),
                    child: TextFormField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        labelText: 'Search',
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 20),
                        border: InputBorder.none,
                      ),
                      onFieldSubmitted: (value) {
                        searchPokemon(value);
                      },
                      onEditingComplete: () {
                        setState(() {
                          currentList = allList;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: currentList.length,
                    itemBuilder: (BuildContext context, index) {
                      return ListItem(
                        index: index,
                        currentList: currentList,
                      );
                      // return ListTile();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: _floatinglocationtop,
            left: 4,
            child: Container(
                width: floatingButtonWidth,
                height: floatingButttonHeight,
                child: FilterButton(
                  type: 'fire',
                )),
          ),
          Positioned(
            top: _floatinglocationtop + 90,
            left: 4,
            child: Container(
              width: 120,
              height: 80,
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentList = grassList;
                    });
                  },
                  child: FilterButton(type: 'grass')),
            ),
          ),
          Positioned(
            top: _floatinglocationtop + 180,
            left: 4,
            child: Container(
              width: 120,
              height: 80,
              child: FilterButton(
                type: 'ice',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final int index;
  final List<Map<String, dynamic>> currentList;
  const ListItem({Key? key, required this.index, required this.currentList})
      : super(key: key);

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  late Future<Pokemon?> _futurePokemon;

  double containerHeight = 200;
  bool _showNothingToSee = false;
  String description = '';
  String currentImage = 'assets/card.png';
  void toggleImage() {
    setState(() {
      var snapshot;
      description = description == ''
          ? '${snapshot.data!.desciption}'
          : currentImage = currentImage == 'assets/card.png'
              ? 'assets/card_expanded.png'
              : 'assets/card.png';
      containerHeight = containerHeight == 200 ? 400 : 200;
    });
  }

  @override
  void initState() {
    super.initState();
    _futurePokemon = getData();
  }

  Future<Pokemon?> getData() async {
    try {
      final directory = await getApplicationCacheDirectory();
      final file = File(
          '${directory.path}/pokemon/${widget.currentList[widget.index]['pokemon']['name']}.json');

      if (!await file.exists()) {
        print('File does not exist. Fetching data from URL...');
        Pokemon? pokemon = await getPokemon(
            widget.currentList[widget.index]['pokemon']['url']);

        // Save Pokemon data to file
        await savePokemon(pokemon);
        print('Pokemon data saved to file.');

        return pokemon;
      } else {
        print('File exists. Loading Pokemon data from file...');
        return await loadPokemon(
            '${widget.currentList[widget.index]['pokemon']['name']}');
      }
    } catch (e) {
      print('Error fetching Pokemon: $e');
      return null; // or throw an error if needed
    }
  }

  Future<void> reloadFutureBuilder() async {
    setState(() {
      _showNothingToSee = false;
      _futurePokemon = getData(); // Reload the future
    });
  }

  void checkForNothingToSee() {
    Timer(Duration(seconds: 10), () {
      if (_showNothingToSee) {
        reloadFutureBuilder();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pokemon?>(
      future: _futurePokemon,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          return GestureDetector(
            onTap: () {
              setState(() {
                description =
                    description == '' ? '${snapshot.data!.description}' : '';

                currentImage = currentImage == 'assets/card.png'
                    ? 'assets/card_expanded.png'
                    : 'assets/card.png';
                containerHeight = containerHeight == 200 ? 400 : 200;
              });
              ;
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              height: containerHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage(currentImage),
                ),
              ),
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '#${widget.index + 1}',
                          style: TextStyle(fontSize: 30),
                        ),
                        SizedBox(
                          height: 100,
                          child: Center(
                            child: Image.network(snapshot.data!.imageUrl),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            snapshot.data!.name,
                            style: TextStyle(
                                fontSize: 20, fontStyle: FontStyle.italic),
                          ),
                          Text(
                            'Type: ${snapshot.data!.type}',
                            style: TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextWithNoNewLines(
                          text: description,
                          softWrap: true,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          _showNothingToSee = true;
          checkForNothingToSee(); // Start the timer to check for "NOTHING TO SEE" state
          return SizedBox(
            child: Text(
              'NOTHING TO SEE',
              style: TextStyle(color: Colors.white),
            ),
          );
          // } else {}
        }
      },
    );
  }
}

class FilterButton extends StatefulWidget {
  final String type;
  const FilterButton({super.key, required this.type});

  @override
  State<FilterButton> createState() => _FilterButtonState(type: type);
}

class _FilterButtonState extends State<FilterButton> {
  final String type;
  _FilterButtonState({required this.type});
  double containerHeight = 200;
  double _elevation1 = 2;

  double floatingButtonWidth = 120;
  double floatingButttonHeight = 80;
  void filterToggleSize() {
    setState(() {
      // var currentType = type;

      if (floatingButtonWidth == 120) {
        floatingButtonWidth = 180;

        _elevation1 = 6;
      } else {
        floatingButtonWidth = 120;

        _elevation1 = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: floatingButtonWidth,
      height: floatingButttonHeight,
      child: RawMaterialButton(
        onPressed: () {
          filterToggleSize();
        },
        shape: CircleBorder(),
        elevation: _elevation1,
        child: Image.asset(
          "assets/${type}.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class TextWithNoNewLines extends StatelessWidget {
  final String text;
  final bool softWrap;

  const TextWithNoNewLines({
    Key? key,
    required this.text,
    this.softWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Preprocess text to remove newlines
    String processedText = text.replaceAll('\n', ' ');

    return Text(
      processedText,
      style: TextStyle(fontSize: 15),
      softWrap: softWrap, // Enable soft wrapping
      textAlign: TextAlign.center,
    );
  }
}
