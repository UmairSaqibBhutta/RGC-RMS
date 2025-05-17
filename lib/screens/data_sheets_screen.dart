import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:path_provider/path_provider.dart'; // For temporary directory
import 'package:open_file/open_file.dart';

class DataSheetScreens extends StatefulWidget {
  const DataSheetScreens({super.key});

  @override
  State<DataSheetScreens> createState() => _DataSheetScreensState();
}

class _DataSheetScreensState extends State<DataSheetScreens> {
  List<DataSheetModel> dataSheet = [
    DataSheetModel(name: 'RL-300', extension: 'pdf', path: 'images/RL-300.pdf'),
    DataSheetModel(name: 'RL-400', extension: 'pdf', path: 'images/RL-400.pdf'),
    DataSheetModel(
        name: 'Mamz BituLastic',
        extension: 'pdf',
        path: 'images/Mamz BituLastic.pdf'),
    DataSheetModel(
        name: 'Catalogue',
        extension: 'docx',
        path: 'images/catalogue page.docx'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Data Sheet',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            for (var l in dataSheet)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 10,
                  child: ListTile(
                      trailing: const Icon(CupertinoIcons.cloud_download_fill),
                      leading: const Icon(CupertinoIcons.doc_fill),
                      onTap: () async {
                        String localPath = await _copyAssetToLocal(l.path!);
                        if (localPath.isNotEmpty) {
                          await OpenFile.open(localPath);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to open ${l.name}'),
                            ),
                          );
                        }
                      },
                      title: Text(l.name.toString())),
                ),
              )
          ],
        ),
      ),
    );
  }

  // Function to copy the asset to a temporary local directory
  Future<String> _copyAssetToLocal(String assetPath) async {
    try {
      // Load the asset file
      final byteData = await rootBundle.load(assetPath);

      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${assetPath.split('/').last}');

      // Write the byte data to the local file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      return file.path; // Return the local file path
    } catch (e) {
      print('Error copying asset to local: $e');
      return ''; // Return an empty string if an error occurs
    }
  }
}

class DataSheetModel {
  String? name;
  String? path;
  String? extension;

  DataSheetModel({this.name, this.extension, this.path});
}
