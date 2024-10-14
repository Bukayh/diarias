import 'package:flutter/material.dart';
import 'app_version1.dart';
import 'app_version2.dart';
import 'app_version3.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

Future<void> _clearData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Remove todos os dados salvos
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicativos Diários',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escolha a Diaria'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh), // Ícone para resetar
            onPressed: () => _mostrarDialogoConfirmacao(
                context, () => _clearData(), "Deseja resetar os dados?"),
            tooltip: 'Resetar', // Exibe uma dica ao passar o mouse ou tocar
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navega para o primeiro aplicativo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppVersion1()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 40, vertical: 20), // Aumenta o tamanho
                textStyle:
                    TextStyle(fontSize: 20), // Aumenta o tamanho do texto
              ),
              child: Text('Diaria 1'),
            ),
            SizedBox(height: 20), // Espaçamento entre os botões
            ElevatedButton(
              onPressed: () {
                // Navega para o segundo aplicativo
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppVersion2()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 40, vertical: 20), // Aumenta o tamanho
                textStyle:
                    TextStyle(fontSize: 20), // Aumenta o tamanho do texto
              ),
              child: Text('Diaria 2'),
            ),
            SizedBox(height: 20), // Espaçamento entre os botões
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppVersion3()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: 40, vertical: 20), // Aumenta o tamanho
                textStyle:
                    TextStyle(fontSize: 20), // Aumenta o tamanho do texto
              ),
              child: Text('Diaria 3'),
            ),
          ],
        ),
      ),
    );
  }
}

void _mostrarDialogoConfirmacao(
    BuildContext context, VoidCallback acao, String mensagem) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Cor de fundo do diálogo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Borda arredondada
        ),
        contentPadding: EdgeInsets.symmetric(
            vertical: 20.0, horizontal: 24.0), // Ajustar o padding
        content: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 300), // Limitar a largura do diálogo
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Minimizar o tamanho da coluna para caber apenas o conteúdo necessário
            children: <Widget>[
              Center(
                child: Text(
                  'Confirmar',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold), // Cor do título
                  textAlign: TextAlign.center, // Centraliza o título
                ),
              ),
              SizedBox(height: 16), // Espaçamento entre título e mensagem
              Center(
                child: Text(
                  mensagem,
                  style: TextStyle(color: Colors.black), // Cor do conteúdo
                  textAlign: TextAlign.center, // Centraliza o conteúdo
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Espaçar os botões nas extremidades
            children: <Widget>[
              TextButton(
                child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop(); // Fechar o diálogo
                },
              ),
              TextButton(
                child: Text('Confirmar', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  acao(); // Executar a ação (incrementar, decrementar, remover)
                  Navigator.of(context).pop(); // Fechar o diálogo
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}
