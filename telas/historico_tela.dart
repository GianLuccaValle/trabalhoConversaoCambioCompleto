import 'package:flutter/material.dart';
import '../modelos/conversao_model.dart';
import 'conversao_tela.dart';

class HistoricoTela extends StatefulWidget {
  const HistoricoTela({super.key});

  @override
  State<HistoricoTela> createState() => _HistoricoTelaState();
}

class _HistoricoTelaState extends State<HistoricoTela> {
  List<ConversaoModel> _historico = [];

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _carregarHistorico() {
    setState(() {
      _historico = ConversaoTela.getHistorico();
    });
  }

  Future<void> _limparHistorico() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Deseja realmente apagar todas as conversões?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirma == true) {
      ConversaoTela.clearHistorico();
      _carregarHistorico();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Histórico limpo com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  String _obterSimboloMoeda(String sigla) {
    const simbolos = {
      'BRL': 'R\$',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'ARS': '\$',
      'JPY': '¥',
    };
    return simbolos[sigla] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Conversões'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_historico.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _limparHistorico,
              tooltip: 'Limpar histórico',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarHistorico,
            tooltip: 'Atualizar',
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
        child: _historico.isEmpty
            ? _buildVazio()
            : RefreshIndicator(
                onRefresh: () async {
                  _carregarHistorico();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _historico.length,
                  itemBuilder: (context, index) {
                    final c = _historico[index];
                    final isParaReal = c.moedaDestino == 'BRL';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.swap_horiz, color: Colors.blue[700], size: 28),
                        ),
                        title: Text(
                          '${_obterSimboloMoeda(c.moedaOrigem)} ${c.valorOrigem.toStringAsFixed(2)} '
                          '→ ${_obterSimboloMoeda(c.moedaDestino)} ${c.valorDestino.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text('${c.moedaOrigem} → ${c.moedaDestino}',
                                style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            Text(
                              'Taxa: ${isParaReal ? c.taxa.toStringAsFixed(2) : (1 / c.taxa).toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  c.formatarData(),
                                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 110, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Nenhuma conversão encontrada',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            'Faça uma conversão para aparecer aqui.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar para Conversão'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}