import 'package:flutter/material.dart';
import 'package:test_flutter_sqlite/database_man.dart';
import 'package:test_flutter_sqlite/logs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter + SQLite CRUD Test',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter And SQLite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEdtControl = TextEditingController();
  final TextEditingController _numberEdtControl = TextEditingController();

  late Future<List<Map<String, dynamic>>> _userListFuture;

  @override
  void initState() {
    super.initState();
    _userListFuture = DatabaseManage.getAllData();
  }

  void addEntry() async {
    String texto = _textEdtControl.text;
    int numero = int.tryParse(_numberEdtControl.text) ?? 0;

    if(texto.isNotEmpty && numero != null && numero > 0) {
      await DatabaseManage.insertUser({'texto': texto, 'numero': numero});

      setState(() {
        _userListFuture = DatabaseManage.getAllData();
      });
    }
    _textEdtControl.clear();
    _numberEdtControl.clear();
  }

  void updateEntry(int userId, String newTexto) async {
    if(newTexto.isNotEmpty) {
      await DatabaseManage.updateUser(userId, newTexto);
    }
    setState(() {
      _userListFuture = DatabaseManage.getAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
        actions: [
          const Text(
            "Logs",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogPage()),
                );
              },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Map<String, dynamic>> users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.indigo,
                child: ListTile(
                  title: Text(
                    "Id: ${users[index]['numero']
                        .toString()} | User: ${users[index]['texto']}",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onLongPress: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Remover"),
                          content: const Text("Remover esse usuário?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancelar"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await DatabaseManage.deleteUser(
                                    users[index]['numero']);
                                setState(() {
                                  _userListFuture = DatabaseManage.getAllData();
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text("Deletar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onTap: () async {
                    TextEditingController _textUpdate = TextEditingController(text: users[index]['texto']);
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: const Text("Editar entrada"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _textUpdate,
                                  decoration: const InputDecoration(labelText: 'Texto'),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Cancelar"),
                              ),
                              ElevatedButton(onPressed: () async{
                                  updateEntry(users[index]['numero'], _textUpdate.text);
                                  Navigator.of(context).pop();
                                },
                                  child: const Text("Salvar")
                              )
                            ],
                          );
                        }
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Nova entrada"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _textEdtControl,
                      decoration: const InputDecoration(labelText: 'Texto'),
                    ),
                    TextField(
                      controller: _numberEdtControl,
                      decoration: const InputDecoration(labelText: 'Numero'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addEntry();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}