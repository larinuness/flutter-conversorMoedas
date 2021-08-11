import 'package:conversormoedas/paletacores.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Uma requisição assincrona é quando você faz porém não fica esperando receber ela(você não trava o problema esperando a reposta)
import 'dart:async';

const request = "https://api.hgbrasil.com/finance/quotations?key=b960949a";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        //Cores da borta
        inputDecorationTheme: InputDecorationTheme(
      //Sem clicar
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black26)),
      //Quando clica, está com foco
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: PaletaCores.amareloMaisEscuro)),
      hintStyle: TextStyle(color: PaletaCores.amareloMaisEscuro),
    )),
  ));
}

//Pegar todos
Future<Map> getData() async {
  //Retorna um dado no futuro
  http.Response response = await http.get(Uri.parse(request));
  //pega o response e transforma o json em um map
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double? dolar;
  double? euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: PaletaCores.amareloMaisEscuro,
        centerTitle: true,
        title: Text(
          ' Conver\$or ',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        //snapshot é um cópia momento que vai fazer dos dados que obter
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(
                      color: PaletaCores.amareloMaisEscuro, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados :(',
                    style: TextStyle(
                        color: PaletaCores.amareloMaisEscuro, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    //Está como strech porque é pra ocupar toda a larguda possivel
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: PaletaCores.amareloEscuro,
                      ),
                      buildTextField('Reais', 'R\$',realController, _realChanged),
                      Divider(),
                      buildTextField('Dolares', 'US\$',dolarController, _dolarChanged),
                      Divider(),
                      buildTextField('Euros', '€',euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget buildTextField(String label, String prefix, TextEditingController c, Function(String) f) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontSize: 20),
        border: OutlineInputBorder(),
        prefixText: prefix,
      ),
      style: TextStyle(color: Colors.black),
      onChanged: f,
    );
  }

  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar!).toStringAsFixed(2);
    euroController.text = (real/euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar!).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro!).toStringAsFixed(2);
    dolarController.text = (euro * this.euro! / dolar!).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
}
