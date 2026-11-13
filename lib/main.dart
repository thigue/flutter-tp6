//THIAGO GUERRA SOARES

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  List<dynamic> receitas = [];

  Future<void> buscarReceitas() async {
    String pesquisa = controller.text.trim();

    final url = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeQueryComponent(pesquisa)}',
    );

    final resposta = await http.get(url);

    final dados = jsonDecode(resposta.body);

    setState(() {
      receitas = dados['meals'] ?? [];
    });
  }

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
              onPressed: buscarReceitas,
              child: Text('Buscar'),
            ),

            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: receitas.length,
                itemBuilder: (context, index) {
                  final receita = receitas[index];

                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        receita['strMealThumb'],
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                      title: Text(receita['strMeal']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}