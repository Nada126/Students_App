// ignore_for_file: unnecessary_null_comparison, camel_case_types, use_super_parameters, library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_app_bar.dart';

class profile_page extends StatefulWidget {
  const profile_page({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<profile_page> {
  late String _userName = ""; // Initialize with an empty string
  late String _userEmail = ""; // Initialize with an empty string
  late String _studentId = ""; // Initialize with an empty string
  late String _userLevel = ""; // Initialize with an empty string
  late File _imageFile = File('assets/default_image.png');

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final loggedInUserEmail = prefs.getString('user_email') ?? '';
    final userData = await _getUserDataFromDatabase(loggedInUserEmail);
    setState(() {
      _userName = userData['name'] ?? '';
      _userEmail = userData['email'] ?? '';
      _studentId = userData['studentId'] ?? '';
      _userLevel = userData['level'] ?? '';
    });
    _loadImage();
  }

  Future<Map<String, dynamic>> _getUserDataFromDatabase(String email) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> users = await db.query(
      'user_data',
      where: 'email = ?',
      whereArgs: [email],
    );
    return users.isNotEmpty ? users.first : {};
  }

  Future<Database> _getDatabase() async {
    final String path = await _localPath;
    return openDatabase(
      '$path/user_data.db',
      version: 1,
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _loadImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? imagePath = prefs.getString('user_image');
    if (imagePath != null) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to the edit page
              await Navigator.pushNamed(context, '/edit');
              // Fetch updated user data when returning from the edit page
              _fetchUserData();
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              DataTable(
                columns: const [
                  DataColumn(label: Text(' ')),
                  DataColumn(label: Text(' ')),
                ],
                rows: [
                  DataRow(cells: [
                    const DataCell(Text('Name')),
                    DataCell(Text(_userName)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Email')),
                    DataCell(Text(_userEmail)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Student ID')),
                    DataCell(Text(_studentId)),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('Level')),
                    DataCell(Text(_userLevel)),
                  ]),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onProfilePressed: () {
          // Navigate to the profile page
          Navigator.pushReplacementNamed(context, '/profile');
        },
        onHomePressed: () {
          // Navigate to the home page
          Navigator.pushReplacementNamed(context, '/main');
        },
      ),
    );
  }
}