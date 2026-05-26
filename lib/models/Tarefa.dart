import 'package:cloud_firestore/cloud_firestore.dart';

class Tarefa {
  final String? id;
  final String titulo;
  final String descricao;
  final String categoria;
  final String prioridade;
  final String status;
  final DateTime? prazo;
  final DateTime criadoEm;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    this.status = 'pendente',
    this.prazo,
    DateTime? criadoEm,
  }) : criadoEm = criadoEm ?? DateTime.now();

  // Converte o objeto para Map antes de salvar no Firestore
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria,
        'prioridade': prioridade,
        'status': status,
        'prazo': prazo != null ? Timestamp.fromDate(prazo!) : null,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };

  // Cria um objeto Tarefa a partir de um documento do Firestore
  factory Tarefa.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Tarefa(
      id: doc.id,
      titulo: d['titulo'] ?? '',
      descricao: d['descricao'] ?? '',
      categoria: d['categoria'] ?? 'Geral',
      prioridade: d['prioridade'] ?? 'Normal',
      status: d['status'] ?? 'pendente',
      prazo: d['prazo'] != null ? (d['prazo'] as Timestamp).toDate() : null,
      criadoEm: d['criadoEm'] != null ? (d['criadoEm'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}