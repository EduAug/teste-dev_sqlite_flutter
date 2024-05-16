import 'package:flutter/material.dart';
import 'package:test_flutter_sqlite/database_man.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late Future<List<Map<String, dynamic>>> _logs;

  @override
  void initState() {
    super.initState();
    _logs = DatabaseManage.getLogs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _logs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Map<String, dynamic>> logs = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: const Text("Logs"),),
          body:ListView.builder(
            itemCount: logs.length,
            itemBuilder: ( context , index) {
              return ListTile(
              title: Text("Operation: ${logs[index]['operacao']}"),
              subtitle: Text("Timestamp: ${logs[index]['datahora']}"),
              );
            },
          ),
        );
      }
    );
  }
}