import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    super.initState();

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);
  }

  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    final isServerConnected = socketService.isServerConnected;

    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: _serverStatus(isServerConnected: isServerConnected),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(itemCount: bands.length, itemBuilder: (context, index) => _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: addNewBand, elevation: 1, child: Icon(Icons.add)),
    );
  }

  Widget _showGraph() {
    if (bands.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text('No data to display', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    final dataMap = {for (var band in bands) band.name: band.votes.toDouble()};

    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        //colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 22,
        legendOptions: const LegendOptions(
          showLegends: true,
          legendPosition: LegendPosition.right,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
      ),
    );
  }

  Widget _serverStatus({required bool isServerConnected}) {
    if (!isServerConnected) {
      bands = [];
      //setState(() {});
    }
    return isServerConnected
        ? Icon(Icons.check_circle, color: Colors.green[300])
        : Icon(Icons.offline_bolt, color: Colors.red);
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      //! On Delete Band
      onDismissed: (_) => socketService.socket.emit('delete-band', {'id': band.id}),
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
        //! Vote for a band
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
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
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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
      ),
    );
  }

  void addBandtoList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (name.length > 1) {
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }
}
