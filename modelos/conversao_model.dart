class ConversaoModel {
  final String moedaOrigem;
  final String moedaDestino;
  final double valorOrigem;
  final double valorDestino;
  final double taxa;
  final DateTime data;

  ConversaoModel({
    required this.moedaOrigem,
    required this.moedaDestino,
    required this.valorOrigem,
    required this.valorDestino,
    required this.taxa,
    required this.data,
  });

  String formatarData() {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}