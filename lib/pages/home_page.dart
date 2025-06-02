import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Bon Jovi', votes: 4),
    Band(id: '3', name: 'White Lies', votes: 2),
    Band(id: '4', name: 'Queen', votes: 3),
    Band(id: '5', name: 'Journey', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(itemCount: bands.length, itemBuilder: (context, index) => _bandTile(bands[index])),
      floatingActionButton: FloatingActionButton(onPressed: addNewBand, elevation: 1, child: Icon(Icons.add)),
    );
  }

  Widget _bandTile(Band band) => Dismissible(
    key: Key(band.id),
    direction: DismissDirection.startToEnd,
    onDismissed: (direction) {
      print('$direction');
      print('id: ${band.id} name: ${band.name}');
      // Delete from server
    },
    background: Container(
      padding: EdgeInsets.only(left: 8.0),
      color: Colors.red,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Delete Band', style: TextStyle(color: Colors.white)),
      ),
    ),
    child: ListTile(
      leading: CircleAvatar(backgroundColor: Colors.blue[100], child: Text(band.name.substring(0, 2))),
      title: Text(band.name),
      trailing: Text('${band.votes}', style: TextStyle(fontSize: 20)),
      onTap: () => print(band.name),
    ),
  );

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New band name:'),
            content: TextField(controller: textController),
            actions: [
              MaterialButton(
                onPressed: () => addBandtoList(textController.text),
                elevation: 5,
                textColor: Colors.blue,
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Band Name'),
          content: CupertinoTextField(controller: textController),
          actions: [
            CupertinoDialogAction(child: Text('Add'), onPressed: () => addBandtoList(textController.text)),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dissmis'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void addBandtoList(String name) {
    print(name);
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
