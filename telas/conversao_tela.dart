import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelos/conversao_model.dart';

class ConversaoTela extends StatefulWidget {
  const ConversaoTela({super.key});

  static List<ConversaoModel> getHistorico() {
    return List.from(_ConversaoTelaState._historico);
  }

  static void clearHistorico() {
    _ConversaoTelaState._historico.clear();
  }

  @override
  State<ConversaoTela> createState() => _ConversaoTelaState();
}

class _ConversaoTelaState extends State<ConversaoTela> {
  final TextEditingController _valorController = TextEditingController();
  String _moedaSelecionada = 'USD';
  String _tipoConversao = 'Real → Moeda';
  double? _resultado;

  static final List<ConversaoModel> _historico = [];

  final Map<String, double> _taxas = {
    'USD': 5.50,
    'EUR': 6.00,
    'GBP': 7.20,
    'ARS': 0.03,
    'JPY': 0.038,
  };

  final Map<String, Map<String, String>> _moedas = {
    'USD': {'nome': 'Dólar', 'simbolo': '\$', 'sigla': 'USD'},
    'EUR': {'nome': 'Euro', 'simbolo': '€', 'sigla': 'EUR'},
    'ARS': {'nome': 'Peso Argentino', 'simbolo': '\$', 'sigla': 'ARS'},
    'GBP': {'nome': 'Libra', 'simbolo': '£', 'sigla': 'GBP'},
    'JPY': {'nome': 'Iene', 'simbolo': '¥', 'sigla': 'JPY'},
  };

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  String _formatarTaxa(double taxa) {
    if (taxa >= 1) {
      return taxa.toStringAsFixed(2);
    } else if (taxa >= 0.01) {
      return taxa.toStringAsFixed(4);
    } else {
      return taxa.toStringAsFixed(6);
    }
  }

  void _converter() {
    if (_valorController.text.isEmpty) {
      _mostrarMensagem('Por favor, insira um valor', Colors.orange[700]!);
      return;
    }

    final double? valor = double.tryParse(_valorController.text.replaceAll(',', '.'));

    if (valor == null || valor <= 0) {
      _mostrarMensagem('Insira um valor válido maior que zero', Colors.orange[700]!);
      return;
    }

    double taxa = _taxas[_moedaSelecionada] ?? 1.0;
    double resultadoCalculo;
    String moedaOrigem;
    String moedaDestino;

    if (_tipoConversao == 'Real → Moeda') {
      resultadoCalculo = valor / taxa;
      moedaOrigem = 'BRL';
      moedaDestino = _moedaSelecionada;
    } else {
      resultadoCalculo = valor * taxa;
      moedaOrigem = _moedaSelecionada;
      moedaDestino = 'BRL';
    }

    setState(() => _resultado = resultadoCalculo);

    final conversao = ConversaoModel(
      moedaOrigem: moedaOrigem,
      moedaDestino: moedaDestino,
      valorOrigem: valor,
      valorDestino: resultadoCalculo,
      taxa: taxa,
      data: DateTime.now(),
    );

    _historico.insert(0, conversao);
    if (_historico.length > 50) {
      _historico.removeLast();
    }

    _mostrarMensagem('Conversão realizada com sucesso!', Colors.green[700]!);
  }

  void _limparCampos() {
    setState(() {
      _valorController.clear();
      _resultado = null;
    });
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _obterSimboloOrigem() {
    return _tipoConversao == 'Real → Moeda' ? 'R\$' : _moedas[_moedaSelecionada]!['simbolo']!;
  }

  String _obterSimboloDestino() {
    return _tipoConversao == 'Real → Moeda' ? _moedas[_moedaSelecionada]!['simbolo']! : 'R\$';
  }

  String _obterNomeDestino() {
    return _tipoConversao == 'Real → Moeda' ? _moedas[_moedaSelecionada]!['nome']! : 'Reais';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversão de Moedas'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            tooltip: 'Ver histórico',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _limparCampos,
            tooltip: 'Limpar campos',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.grey[100]!],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700]),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                '1 ${_moedas[_moedaSelecionada]!['sigla']} = R\$ ${_formatarTaxa(_taxas[_moedaSelecionada]!)}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Taxas fixas (offline)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _tipoConversao,
                            decoration: InputDecoration(
                              labelText: 'Tipo de Conversão',
                              prefixIcon: Icon(Icons.swap_horiz, color: Colors.blue[700]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: false,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Real → Moeda', child: Text('Real → Moeda Estrangeira')),
                              DropdownMenuItem(value: 'Moeda → Real', child: Text('Moeda Estrangeira → Real')),
                            ],
                            onChanged: (String? novoValor) {
                              setState(() {
                                _tipoConversao = novoValor!;
                                _resultado = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _valorController,
                          decoration: InputDecoration(
                            labelText: _tipoConversao == 'Real → Moeda' ? 'Valor em Reais (R\$)' : 'Valor em ${_moedas[_moedaSelecionada]!['nome']}',
                            prefixIcon: Icon(Icons.attach_money, color: Colors.green[700]),
                            hintText: '0,00',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
                          ],
                          onChanged: (value) {
                            if (_resultado != null) setState(() => _resultado = null);
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          initialValue: _moedaSelecionada,
                          decoration: InputDecoration(
                            labelText: 'Selecione a Moeda',
                            prefixIcon: Icon(Icons.currency_exchange, color: Colors.blue[700]),
                          ),
                          items: _moedas.keys.map((String moeda) {
                            return DropdownMenuItem<String>(
                              value: moeda,
                              child: Row(
                                children: [
                                  Text(_moedas[moeda]!['simbolo']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                  Text(_moedas[moeda]!['nome']!),
                                  const SizedBox(width: 5),
                                  Text('(${_moedas[moeda]!['sigla']})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? novoValor) {
                            setState(() {
                              _moedaSelecionada = novoValor!;
                              _resultado = null;
                            });
                          },
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _converter,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Converter'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _limparCampos,
                              icon: const Icon(Icons.clear),
                              label: const Text('Limpar'),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_resultado != null)
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(scale: value, child: child),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.green[700]!, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700], size: 48),
                            const SizedBox(height: 15),
                            Text('Resultado', style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                            const SizedBox(height: 10),
                            Text(
                              '${_obterSimboloDestino()} ${_resultado!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.green[700]),
                            ),
                            const SizedBox(height: 5),
                            Text(_obterNomeDestino(), style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            const SizedBox(height: 15),
                            const Divider(),
                            const SizedBox(height: 10),
                            Text(
                              '${_obterSimboloOrigem()} ${_valorController.text} = ${_obterSimboloDestino()} ${_resultado!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}