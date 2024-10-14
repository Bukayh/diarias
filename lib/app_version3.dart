import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppVersion3 extends StatefulWidget {
  @override
  _AppVersion3State createState() => _AppVersion3State();
}

class _AppVersion3State extends State<AppVersion3> {
  final _nomeController = TextEditingController();
  String? _nome;
  String? _maquinaSelecionada;

final List<String> _maquinasCaminhoes = [
    'CB-101 (2711)',
    'CB-102 (2732)',
    'CB-172 (3294)',
    'CB-180 (3671)',
    'CB-182 (3668)',
    'CP-501 (0672)',
  ];

  final List<String> _maquinasCarregadeirasEscavadeiras = [
    'CA-301 (2534)',
    'CA-303 (3006)',
    'EC-401 (2512)',
    'EC-402 (2513)',
    'EC-432 (2748)',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // Carregar dados salvos ao iniciar
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nome = prefs.getString('app3_nome') ?? '';
      _maquinaSelecionada = prefs.getString('app3_maquinaSelecionada');
      _nomeController.text = _nome ?? '';
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('app3_nome', _nomeController.text);
    if (_maquinaSelecionada != null) {
      await prefs.setString('app3_maquinaSelecionada', _maquinaSelecionada!);
    }
  }

  void _salvarNomeEMaquina() {
    setState(() {
      _nome = _nomeController.text;
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informe os dados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Selecione o equipamento'),
              value: _maquinaSelecionada,
              items: [
                ..._maquinasCaminhoes,
                ..._maquinasCarregadeirasEscavadeiras
              ].map((String maquina) {
                return DropdownMenuItem<String>(
                  value: maquina,
                  child: Text(maquina),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _maquinaSelecionada = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do colaborador'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_maquinaSelecionada != null &&
                    _nomeController.text.isNotEmpty) {
                  _salvarNomeEMaquina();
                  if (_maquinasCaminhoes.contains(_maquinaSelecionada)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaminhaoScreen(
                          nome: _nome!,
                          maquina: _maquinaSelecionada!,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EscavadeiraScreen(
                          nome: _nome!,
                          maquina: _maquinaSelecionada!,
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Por favor, informe o nome e selecione o equipamento.'),
                    ),
                  );
                  _saveData();
                }
              },
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class CaminhaoScreen extends StatefulWidget {
  final String nome;
  final String maquina;

  CaminhaoScreen({required this.nome, required this.maquina});

  @override
  _CaminhaoScreenState createState() => _CaminhaoScreenState();
}

class _CaminhaoScreenState extends State<CaminhaoScreen> {
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _kmInicialController = TextEditingController();
  final TextEditingController _horaInicialController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String? _turnoSelecionado;

  @override
  void initState() {
    super.initState();
    _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _horaInicialController.text = DateFormat('HH:mm').format(DateTime.now());
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _horimetroInicialController.text =
          prefs.getString('app3_horimetroInicial') ?? '';
      _kmInicialController.text = prefs.getString('app3_kmInicial') ?? '';
      _turnoSelecionado = prefs.getString('app3_turno');
      _dataController.text = prefs.getString('app3_data') ??
          DateFormat('dd/MM/yyyy').format(DateTime.now());
      _horaInicialController.text = prefs.getString('app3_horaInicial') ??
          DateFormat('HH:mm').format(DateTime.now());
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Salvar horímetro inicial, garantindo que não seja nulo ou vazio
    if (_horimetroInicialController.text.isNotEmpty) {
      await prefs.setString(
          'app3_horimetroInicial', _horimetroInicialController.text);
    } else {
      await prefs.remove('app3_horimetroInicial'); // Remove se for vazio
    }

    // Salvar KM inicial, garantindo que não seja nulo ou vazio
    if (_kmInicialController.text.isNotEmpty) {
      await prefs.setString('app3_kmInicial', _kmInicialController.text);
    } else {
      await prefs.remove('app3_kmInicial'); // Remove se for vazio
    }

    // Salvar turno (usa valor padrão se não estiver selecionado)
    await prefs.setString('app3_turno',
        _turnoSelecionado ?? '1'); // Define turno 1 como padrão se nulo

    // Salvar data, garantindo que não seja nulo ou vazio
    if (_dataController.text.isNotEmpty) {
      await prefs.setString('app3_data', _dataController.text);
    } else {
      await prefs.remove('app3_data'); // Remove se for vazio
    }

    // Salvar hora inicial, garantindo que não seja nulo ou vazio
    if (_horaInicialController.text.isNotEmpty) {
      await prefs.setString('app3_horaInicial', _horaInicialController.text);
    } else {
      await prefs.remove('app3_horaInicial'); // Remove se for vazio
    }
  }

  @override
  void dispose() {
    _horimetroInicialController.dispose();
    _kmInicialController.dispose();
    _horaInicialController.dispose();
    _dataController.dispose();
    super.dispose();
    _loadSavedData();
  }

  void _navegarParaViagens() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViagensScreen(
          nome: widget.nome,
          maquina: widget.maquina,
          horimetroInicial: _horimetroInicialController.text,
          kmInicial: _kmInicialController.text,
          turno: _turnoSelecionado!,
          data: _dataController.text,
          horaInicial: _horaInicialController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dados do Caminhão: ${widget.maquina}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _horimetroInicialController,
                decoration: InputDecoration(labelText: 'Horímetro Inicial'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _kmInicialController,
                decoration: InputDecoration(labelText: 'KM Inicial'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Turno'),
                value: _turnoSelecionado,
                items: ['1', '2', '3'].map((String turno) {
                  return DropdownMenuItem<String>(
                    value: turno,
                    child: Text(turno),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _turnoSelecionado = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dataController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _horaInicialController,
                decoration: InputDecoration(labelText: 'Hora Inicial'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _horaInicialController.text =
                          pickedTime.format(context).toString();
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_horimetroInicialController.text.isNotEmpty &&
                      _kmInicialController.text.isNotEmpty &&
                      _turnoSelecionado != null &&
                      _dataController.text.isNotEmpty &&
                      _horaInicialController.text.isNotEmpty) {
                    _navegarParaViagens();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Por favor, preencha todos os campos antes de continuar.'),
                      ),
                    );
                  }
                  _saveData();
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EscavadeiraScreen extends StatefulWidget {
  final String nome;
  final String maquina;

  EscavadeiraScreen({required this.nome, required this.maquina});

  @override
  _EscavadeiraScreenState createState() => _EscavadeiraScreenState();
}

class _EscavadeiraScreenState extends State<EscavadeiraScreen> {
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _horaInicialController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  String? _turnoSelecionado;

  @override
  void initState() {
    super.initState();
    _dataController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _horaInicialController.text = DateFormat('HH:mm').format(DateTime.now());
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _horimetroInicialController.text =
          prefs.getString('app3_horimetroInicial') ?? '';
      _turnoSelecionado = prefs.getString('app3_turno');
      _dataController.text = prefs.getString('app3_data') ??
          DateFormat('dd/MM/yyyy').format(DateTime.now());
      _horaInicialController.text = prefs.getString('app3_horaInicial') ??
          DateFormat('HH:mm').format(DateTime.now());
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'app3_horimetroInicial', _horimetroInicialController.text);
    await prefs.setString('app3_turno', _turnoSelecionado ?? '');
    await prefs.setString('app3_data', _dataController.text);
    await prefs.setString('app3_horaInicial', _horaInicialController.text);
  }

  @override
  void dispose() {
    _horimetroInicialController.dispose();
    _horaInicialController.dispose();
    _dataController.dispose();
    super.dispose();
    _loadSavedData();
  }

  void _navegarParaViagens() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViagensScreen(
          nome: widget.nome,
          maquina: widget.maquina,
          horimetroInicial: _horimetroInicialController.text,
          kmInicial: null, // Não aplicável para carregadeiras e escavadeiras
          turno: _turnoSelecionado!,
          data: _dataController.text,
          horaInicial: _horaInicialController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dados da Máquina: ${widget.maquina}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _horimetroInicialController,
                decoration: InputDecoration(labelText: 'Horímetro Inicial'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Turno'),
                value: _turnoSelecionado,
                items: ['1', '2', '3'].map((String turno) {
                  return DropdownMenuItem<String>(
                    value: turno,
                    child: Text(turno),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _turnoSelecionado = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dataController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              TextField(
                controller: _horaInicialController,
                decoration: InputDecoration(labelText: 'Hora Inicial'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _horaInicialController.text =
                          pickedTime.format(context).toString();
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_horimetroInicialController.text.isNotEmpty &&
                      _turnoSelecionado != null &&
                      _dataController.text.isNotEmpty &&
                      _horaInicialController.text.isNotEmpty) {
                    _navegarParaViagens();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Por favor, preencha todos os campos antes de continuar.'),
                      ),
                    );
                  }
                  _saveData();
                },
                child: Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViagensScreen extends StatefulWidget {
  final String nome;
  final String maquina;
  final String horimetroInicial;
  final String? kmInicial;
  final String turno;
  final String data;
  final String horaInicial;

  ViagensScreen({
    required this.nome,
    required this.maquina,
    required this.horimetroInicial,
    this.kmInicial,
    required this.turno,
    required this.data,
    required this.horaInicial,
  });

  final List<String> _listaEquipamentos = [
    'CA-301 (2534)',
    'CA-303 (3006)',
    'EC-401 (2512)',
    'EC-402 (2513)',
    'EC-432 (2748)',
  ];

  @override
  _ViagensScreenState createState() => _ViagensScreenState();
}

class _ViagensScreenState extends State<ViagensScreen> {
  final List<ViagemPredefinida> _viagensPredefinidas = [
    ViagemPredefinida(origem: 'MINA', destino: 'BRITADOR'),
    ViagemPredefinida(origem: 'MINA', destino: 'PÁTIO ESTOQUE'),
    ViagemPredefinida(origem: 'PÁTIO', destino: 'BRITADOR'),
    ViagemPredefinida(
        origem: 'BRITA 0', destino: 'ESTRADAS INTERNAS / EXTERNAS'),
    ViagemPredefinida(
        origem: 'BRITA 1', destino: 'ESTRADAS INTERNAS / EXTERNAS'),
    ViagemPredefinida(
        origem: 'BRITA 2', destino: 'ESTRADAS INTERNAS / EXTERNAS'),
    ViagemPredefinida(
        origem: 'BRITA 3', destino: 'ESTRADAS INTERNAS / EXTERNAS'),
    ViagemPredefinida(origem: 'MINÉRIO CONTAMINADO', destino: 'BOTA FORA'),
    ViagemPredefinida(origem: 'REJEITO', destino: 'ESTRADAS / BOTA FORA'),
    ViagemPredefinida(origem: 'DECAPE', destino: 'BOTA FORA'),
    ViagemPredefinida(origem: 'CASCALHO', destino: 'ESTRADAS'),
  ];
  List<ViagemPredefinida> _viagens = [];
  List<ViagemAtipica> _viagensAtipicas = [];
  int _contadorAtipicas = 0;
  final TextEditingController _horimetroFinalController = TextEditingController();
  final TextEditingController _horaFinalController = TextEditingController();
  final TextEditingController _kmFinalController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _viagens = _viagensPredefinidas
        .map((viagem) => ViagemPredefinida(
              origem: viagem.origem,
              destino: viagem.destino,
              contador: 0,
              maquinaSelecionada: null, // Inicialmente sem máquina selecionada
            ))
        .toList();
    _carregarDados();
    _carregarDados2();
    _carregarDadosFinalizacao();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    // Carregar contadores das viagens predefinidas
    for (var i = 0; i < _viagens.length; i++) {
      setState(() {
        _viagens[i].contador = prefs.getInt('app3_viagem_${i}_contador') ?? 0;
        _viagens[i].maquinaSelecionada =
            prefs.getString('app3_viagem_${i}_maquina');
      });
    }

    // Carregar viagens atípicas
    setState(() {
      _contadorAtipicas = prefs.getInt('app3_contador_atipicas') ?? 0;
    });

    // Carregar viagens atípicas
    for (var i = 0; i < _contadorAtipicas; i++) {
      setState(() {
        _viagensAtipicas.add(ViagemAtipica(
          id: i + 1,
          observacaoController: TextEditingController(
            text: prefs.getString('app3_viagem_atipica_${i}') ?? '',
          ),
          maquinaSelecionada:
              prefs.getString('app3_viagem_atipica_${i}_maquina'),
        ));
      });
    }
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvar contadores das viagens predefinidas e a máquina selecionada
    for (var i = 0; i < _viagens.length; i++) {
      await prefs.setInt('app3_viagem_${i}_contador', _viagens[i].contador);

      // Verifica se a máquina foi selecionada antes de salvar
      if (_viagens[i].maquinaSelecionada != null &&
          _viagens[i].maquinaSelecionada!.isNotEmpty) {
        await prefs.setString(
            'app3_viagem_${i}_maquina', _viagens[i].maquinaSelecionada!);
      } else {
        await prefs.remove(
            'app3_viagem_${i}_maquina'); // Remove se não houver máquina selecionada
      }
    }
    // Salvar viagens atípicas e a máquina selecionada
    await prefs.setInt('app3_contador_atipicas', _contadorAtipicas);
    for (var i = 0; i < _viagensAtipicas.length; i++) {
      await prefs.setString('app3_viagem_atipica_${i}',
          _viagensAtipicas[i].observacaoController.text);

      // Verifica se a máquina foi selecionada antes de salvar
      if (_viagensAtipicas[i].maquinaSelecionada != null &&
          _viagensAtipicas[i].maquinaSelecionada!.isNotEmpty) {
        await prefs.setString('app3_viagem_atipica_${i}_maquina',
            _viagensAtipicas[i].maquinaSelecionada!);
      } else {
        await prefs.remove(
            'app3_viagem_atipica_${i}_maquina'); // Remove se não houver máquina selecionada
      }
    }
  }

// Função para salvar os dados no SharedPreferences
  Future<void> _salvarDados2() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> viagensEncoded = _viagens.map((viagem) {
      return jsonEncode({
        'app3_origem': viagem.origem,
        'app3_destino': viagem.destino,
        'app3_contador': viagem.contador,
        'app3_maquinaSelecionada': viagem.maquinaSelecionada,
      });
    }).toList();
    await prefs.setStringList('app3_viagens_salvas', viagensEncoded);
  }

// Função para carregar os dados do SharedPreferences
  Future<void> _carregarDados2() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? viagensEncoded = prefs.getStringList('app3_viagens_salvas');
    if (viagensEncoded != null) {
      setState(() {
        _viagens = viagensEncoded.map((viagemStr) {
          Map<String, dynamic> viagemMap = jsonDecode(viagemStr);
          return ViagemPredefinida(
            origem: viagemMap['app3_origem'],
            destino: viagemMap['app3_destino'],
            contador: viagemMap['app3_contador'],
            maquinaSelecionada: viagemMap['app3_maquinaSelecionada'],
          );
        }).toList();
      });
    }
  }

  void _adicionarViagemAtipica() {
    setState(() {
      _contadorAtipicas++;
      _viagensAtipicas.add(ViagemAtipica(
        id: _contadorAtipicas,
        observacaoController: TextEditingController(),
        maquinaSelecionada: null, // Inicialmente sem máquina selecionada
      ));
    });
    _salvarDados();
  }

  void _removerViagemAtipica(int id) {
    setState(() {
      _viagensAtipicas.removeWhere((viagem) => viagem.id == id);
      for (int i = 0; i < _viagensAtipicas.length; i++) {
        _viagensAtipicas[i].id = i + 1;
      }
      _contadorAtipicas = _viagensAtipicas.length;
    });
    _salvarDados();
  }

  void _incrementarViagem(int index) {
    setState(() {
      _viagens[index].contador++;
    });
    _salvarDados();
    _salvarDados2();
  }

  void _decrementarViagem(int index) {
    setState(() {
      if (_viagens[index].contador > 0) {
        _viagens[index].contador--;
      }
    });
    _salvarDados();
    _salvarDados2();
  }

  void _finalizarViagem() {
    // A lógica da finalização continua a mesma
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Finalizar Viagem'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _horimetroFinalController,
                  decoration: InputDecoration(labelText: 'Horímetro Final'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                if (widget.kmInicial != null)
                  TextField(
                    controller: _kmFinalController,
                    decoration: InputDecoration(labelText: 'KM Final'),
                    keyboardType: TextInputType.number,
                  ),
                SizedBox(height: 20),
                TextField(
                  controller: _horaFinalController,
                  decoration: InputDecoration(labelText: 'Hora Final'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _horaFinalController.text =
                            pickedTime.format(context).toString();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Salvar e Compartilhar os Dados
                _compartilharDados(
                  horimetroFinal: _horimetroFinalController.text,
                  horaFinal: _horaFinalController.text,
                  kmFinal:
                      widget.kmInicial != null ? _kmFinalController.text : null,
                );
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('Compartilhar'),
            ),
            TextButton(
              onPressed: () {
                // Salvar e Compartilhar os Dados
              _salvarDadosFinalizacao();
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
Future<void> _carregarDadosFinalizacao() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    _horimetroFinalController.text = prefs.getString('app3_horimetroFinal') ?? '';
    _horaFinalController.text = prefs.getString('app3_horaFinal') ?? '';
    _kmFinalController.text = prefs.getString('app3_kmFinal') ?? '';
  });
}  
Future<void> _salvarDadosFinalizacao() async {
  final prefs = await SharedPreferences.getInstance();

  // Salvar horímetro final, garantindo que não seja nulo ou vazio
  if (_horimetroFinalController.text.isNotEmpty) {
    await prefs.setString('app3_horimetroFinal', _horimetroFinalController.text);
  } else {
    await prefs.remove('app3_horimetroFinal'); // Remove se for vazio
  }

  // Salvar hora final, garantindo que não seja nulo ou vazio
  if (_horaFinalController.text.isNotEmpty) {
    await prefs.setString('app3_horaFinal', _horaFinalController.text);
  } else {
    await prefs.remove('app3_horaFinal'); // Remove se for vazio
  }

  // Salvar KM final, garantindo que não seja nulo ou vazio
  if (_kmFinalController.text.isNotEmpty) {
    await prefs.setString('app3_kmFinal', _kmFinalController.text);
  } else {
    await prefs.remove('app3_kmFinal'); // Remove se for vazio
  }
}
  void _compartilharDados({
    required String horimetroFinal,
    required String horaFinal,
    String? kmFinal,
  }) async {
    String dados = '''
Nome: ${widget.nome}
Equipamento: ${widget.maquina}
Horímetro Inicial: ${widget.horimetroInicial}
${widget.kmInicial != null ? 'KM Inicial: ${widget.kmInicial}' : ''}
Turno: ${widget.turno}
Data: ${widget.data}
Hora Inicial: ${widget.horaInicial}

Viagens:
''';

    for (var viagem in _viagens) {
      if (viagem.contador > 0) {
        dados += '- ${viagem.origem} → ${viagem.destino} x${viagem.contador}\n';
        if (viagem.maquinaSelecionada != null &&
            viagem.maquinaSelecionada!.isNotEmpty) {
          dados += '  Máquina: ${viagem.maquinaSelecionada}\n';
        }
      }
    }

    for (var atipica in _viagensAtipicas) {
      dados +=
          'OBESERVAÇÃO ${atipica.id}: \n"${atipica.observacaoController.text}"\n';
    }

    dados += '''
Horímetro Final: $horimetroFinal
${kmFinal != null ? 'KM Final: $kmFinal' : ''}
Hora Final: $horaFinal
''';

    // Salvar os dados usando shared_preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app3_dados_viagem', dados);

    Share.share(dados, subject: 'Dados de Viagem');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viagens'),
        actions: [
          IconButton(
            icon: Icon(Icons.add), // Ícone de adicionar
            onPressed:
                _adicionarViagemPredefinida, // Chama a função para adicionar viagem
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _viagens.length + _viagensAtipicas.length,
                itemBuilder: (context, index) {
                  if (index < _viagens.length) {
                    // Viagem Predefinida com Dropdown para selecionar máquina
                    return ListTile(
                      title: Text(
                          '${_viagens[index].origem} → ${_viagens[index].destino}'),
                      subtitle: DropdownButton<String>(
                        hint: Text('Selecione a máquina'),
                        value: _viagens[index].maquinaSelecionada,
                        onChanged: (String? newValue) {
                          setState(() {
                            _viagens[index].maquinaSelecionada = newValue;
                          });
                          _salvarDados();
                        },
                        items: widget._listaEquipamentos.map((String maquina) {
                          return DropdownMenuItem<String>(
                            value: maquina,
                            child: Text(maquina),
                          );
                        }).toList(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => _mostrarDialogoConfirmacao(
                              context,
                              () => _decrementarViagem(index),
                              "Deseja remover uma viagem?",
                            ),
                          ),
                          Text('${_viagens[index].contador}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _mostrarDialogoConfirmacao(
                              context,
                              () => _incrementarViagem(index),
                              "Deseja adicionar uma viagem?",
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    int atipicaIndex = index - _viagens.length;
                    ViagemAtipica atipica = _viagensAtipicas[atipicaIndex];
                    return ListTile(
                      title: Text('OBSERVAÇÃO ${atipica.id}'),
                      subtitle: Column(
                        children: [
                          TextField(
                            controller: atipica.observacaoController,
                            decoration:
                                InputDecoration(labelText: 'Observação'),
                            onChanged: (value) {
                              _salvarDados();
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          _removerViagemAtipica(atipica.id);
                          _salvarDados();
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _adicionarViagemAtipica,
                  child: Text('+ Adicionar uma observação'),
                ),
                ElevatedButton(
                  onPressed: _finalizarViagem,
                  child: Text('Finalizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _adicionarViagemPredefinida() {
    String? origem;
    String? destino;
    String? maquinaSelecionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adicionar Viagem Extra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Origem'),
                onChanged: (value) {
                  origem = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Destino'),
                onChanged: (value) {
                  destino = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (origem != null && destino != null) {
                  setState(() {
                    _viagens.add(ViagemPredefinida(
                      origem: origem!,
                      destino: destino!,
                      contador: 0,
                      maquinaSelecionada: maquinaSelecionada,
                    ));
                  });
                  _salvarDados2(); // Salvar os dados após a adição
                  Navigator.of(context).pop(); // Fechar o diálogo
                }
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
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

class ViagemPredefinida {
  final String origem;
  final String destino;
  int contador;
  String? maquinaSelecionada; // Máquina selecionada para a viagem

  ViagemPredefinida({
    required this.origem,
    required this.destino,
    this.contador = 0,
    this.maquinaSelecionada, // Inicialmente null
  });
}

class ViagemAtipica {
  int id;
  final TextEditingController observacaoController;
  String? maquinaSelecionada; // Máquina selecionada para a viagem atípica

  ViagemAtipica({
    required this.id,
    required this.observacaoController,
    this.maquinaSelecionada, // Inicialmente null
  });
}