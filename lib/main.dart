//THIAGO GUERRA SOARES

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReceitaPage(),
    );
  }
}

class ReceitaPage extends StatefulWidget {
  const ReceitaPage({super.key});

  @override
  State<ReceitaPage> createState() => _ReceitaPageState();
}

class _ReceitaPageState extends State<ReceitaPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receitas - THIAGO GUERRA SOARES'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Digite o nome da receita',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pesquisa: ${controller.text}'),
                  ),
                );
              },
              child: Text('Buscar'),
            ),
            SizedBox(height: 20),
            Text('As receitas aparecerão aqui.'),
          ],
        ),
      ),
    );
  }
}