//THIAGO GUERRA SOARES

import 'dart:convert';
import 'package:flutter/material.dart';
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
  bool carregando = false;
  String mensagem = 'Pesquise uma receita para começar.';

  Future<void> buscarReceitas() async {
    String pesquisa = controller.text.trim();

    if (pesquisa.isEmpty) {
      setState(() {
        receitas = [];
        mensagem = 'Digite o nome de uma receita.';
      });
      return;
    }

    setState(() {
      carregando = true;
      receitas = [];
      mensagem = '';
    });

    try {
      final url = Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeQueryComponent(pesquisa)}',
      );

      final resposta = await http.get(url).timeout(
        const Duration(seconds: 15),
      );

      if (resposta.statusCode != 200) {
        throw Exception('Erro na consulta');
      }

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;

      setState(() {
        receitas = dados['meals'] ?? [];

        if (receitas.isEmpty) {
          mensagem = 'Nenhuma receita encontrada.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        mensagem = 'Erro ao buscar receitas. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
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
              onPressed: carregando ? null : buscarReceitas,
              child: Text('Buscar'),
            ),

            SizedBox(height: 20),

            Expanded(
              child: carregando
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : receitas.isEmpty
                      ? Center(
                          child: Text(mensagem),
                        )
                      : ListView.builder(
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.broken_image);
                                  },
                                ),
                                title: Text(receita['strMeal']),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetalheReceitaPage(
                                        receita: receita,
                                      ),
                                    ),
                                  );
                                },
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

// Tela que mostra os detalhes da receita
class DetalheReceitaPage extends StatelessWidget {
  final Map<String, dynamic> receita;

  const DetalheReceitaPage({
    super.key,
    required this.receita,
  });

  @override
  Widget build(BuildContext context) {
    List<String> ingredientes = [];

    // A API possui até 20 ingredientes por receita
    for (int i = 1; i <= 20; i++) {
      String ingrediente = (receita['strIngredient$i'] ?? '').toString().trim();
      String medida = (receita['strMeasure$i'] ?? '').toString().trim();

      if (ingrediente.isNotEmpty) {
        ingredientes.add('$medida $ingrediente'.trim());
      }
    }

    String instrucoes = receita['strInstructions'] ?? '';
    String imagem = receita['strMealThumb'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Receita'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagem.isNotEmpty)
                Image.network(
                  imagem,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Imagem indisponível');
                  },
                ),

              SizedBox(height: 15),

              Text(
                receita['strMeal'] ?? '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Ingredientes:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              for (String ingrediente in ingredientes)
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text('- $ingrediente'),
                ),

              SizedBox(height: 20),

              Text(
                'Modo de preparo:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10),

              Text(
                instrucoes.isEmpty
                    ? 'Modo de preparo não disponível.'
                    : instrucoes,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}