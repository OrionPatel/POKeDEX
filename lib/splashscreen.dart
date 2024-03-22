import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pokedex_v3/models.dart';
import 'service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void pushReplacement(BuildContext context) {
    context.go('/home', extra: 'Data from splash Screen');
  }

  Future<void> _initialize() async {
    List<String> types = ['fire', 'grass', 'ice'];
    for (var type in types) {
      final directory = await getApplicationCacheDirectory();
      final file = File('${directory.path}/${type}list.json');
      if (!await file.exists()) {
        if (type == 'fire') {
          List<Map<String, dynamic>> fireList = await getpokeList('fire');
          saveList('fire', fireList);
        } else if (type == 'grass') {
          List<Map<String, dynamic>> grassList = await getpokeList('grass');
          saveList('grass', grassList);
        } else {
          List<Map<String, dynamic>> iceList = await getpokeList('ice');
          saveList('ice', iceList);
        }
      }
      print('$type file now exists');
      // loadPokeList(type);
    }

    Future.delayed(Duration(seconds: 1), () => pushReplacement(context));
  }

  @override
  void initState() {
    super.initState();
    print('initialize being called');
    _initialize();

    //_checkDataAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            Image.asset('assets/splash_screen.jpg'),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
