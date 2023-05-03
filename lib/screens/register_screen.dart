import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Map<String, String> regions = {};
  Map<String, String> provinces = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  Future<void> callAPI() async {
    //https://psgc.gitlab.io/api/island-groups/
    var url = Uri.https('psgc.gitlab.io', 'api/island-groups/');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    List decodedResponse = jsonDecode(response.body);
    decodedResponse.forEach((element) {
      Map item = element;
      print(item['name']);
    });
  }

  Future<void> loadRegions() async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/');
    var response = await http.get(url);
    print('regions ${response.body}');
    if (response.statusCode == 200) {
      List decodedResponse = jsonDecode(response.body);
      decodedResponse.forEach((element) {
        Map item = element;
        //map key-code, value-regionname
        regions.addAll({item['code']: item['regionName']});
      });
    }

    setState(() {
      isRegionsLoaded = true;
    });
    // print(regions);
  }

  Future<void> loadProvinces(String regionCode) async {
    var url = Uri.https('psgc.gitlab.io', 'api/regions/$regionCode/provinces/');
    var response = await http.get(url);
    // print(response.body);

    provinces.clear();
    if (response.statusCode == 200) {
      List decodedResponse = jsonDecode(response.body);
      decodedResponse.forEach((element) {
        Map item = element;
        //map key-code, value-regionname
        provinces.addAll({item['code']: item['name']});
      });
    }
    setState(() {
      isProvincesLoaded = true;
    });
    print(provinces);
  }

  Future<void> register() async {
    var url = Uri.parse('http://192.168.0.104/flutter_3c_php/register.php');
    var response = await http.post(url, body: {
      'username': _usernameController.text,
      'province': _provinceController.text
    });
    print(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isRegionsLoaded)
            DropdownMenu(
              label: const Text('Regions'),
              enableSearch: true,
              // enableFilter: true,
              dropdownMenuEntries: regions.entries.map((item) {
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              onSelected: (value) {
                print(value);
                setState(() {
                  isProvincesLoaded = false;
                });
                loadProvinces(value!);
              },
            )
          else
            Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 8,
          ),
          if (isProvincesLoaded)
            DropdownMenu(
              controller: _provinceController,
              label: const Text('Provinces'),
              enableSearch: true,
              // enableFilter: true,
              dropdownMenuEntries: provinces.entries.map((item) {
                return DropdownMenuEntry(value: item.key, label: item.value);
              }).toList(),
              initialSelection: provinces.entries.first.key,
              onSelected: (value) {
                print(value);
              },
            )
          else
            DropdownMenu(dropdownMenuEntries: []),
          TextField(
            controller: _usernameController,
          ),
          ElevatedButton(
            onPressed: register,
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}
