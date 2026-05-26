import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tarefa.dart';
import '../utils/estilos.dart';

class TarefaFormScreen extends StatefulWidget {
  // Se tarefa for null, estamos criando. Se não, estamos editando.
  final Tarefa? tarefa;
  const TarefaFormScreen({super.key, this.tarefa});

  @override
  State<TarefaFormScreen> createState() => _TarefaFormScreenState();
}

class _TarefaFormScreenState extends State<TarefaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  String _categoria = 'Trabalho';
  String _prioridade = 'Normal';
  String _status = 'pendente';
  DateTime? _prazo;
  bool _salvando = false;

  final _categorias = ['Trabalho', 'Estudo', 'Pessoal', 'Saúde', 'Geral'];
  final _prioridades = ['Baixa', 'Normal', 'Alta'];

  // Referência para a coleção do usuário no Firestore
  CollectionReference get _colecao {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('tarefas');
  }

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos com os dados existentes
    if (widget.tarefa != null) {
      final t = widget.tarefa!;
      _tituloCtrl.text = t.titulo;
      _descricaoCtrl.text = t.descricao;
      _categoria = t.categoria;
      _prioridade = t.prioridade;
      _status = t.status;
      _prazo = t.prazo;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final tarefa = Tarefa(
        titulo: _tituloCtrl.text.trim(),
        descricao: _descricaoCtrl.text.trim(),
        categoria: _categoria,
        prioridade: _prioridade,
        status: _status,
        prazo: _prazo,
        criadoEm: widget.tarefa?.criadoEm,
      );

      if (widget.tarefa?.id != null) {
        // Atualiza documento existente
        await _colecao.doc(widget.tarefa!.id).update(tarefa.toMap());
      } else {
        // Cria novo documento
        await _colecao.add(tarefa.toMap());
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) mostrarErro(context, 'Erro ao salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _prazo ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) setState(() => _prazo = data);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.tarefa != null;

    return Scaffold(
      backgroundColor: kFundo,
      appBar: AppBar(
        backgroundColor: kAzul,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(editando ? 'Editar tarefa' : 'Nova tarefa'),
        actions: [
          if (_salvando)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _salvar,
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              label('Título'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tituloCtrl,
                decoration: inputDecor('Ex: Estudar Flutter', Icons.title),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o título.';
                  if (v.trim().length < 3) return 'Mínimo de 3 caracteres.';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Descrição
              label('Descrição'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                decoration: inputDecor('Detalhes da tarefa...', Icons.notes).copyWith(alignLabelWithHint: true),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição.' : null,
              ),
              const SizedBox(height: 18),

              // Categoria e Prioridade lado a lado
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('Categoria'),
                        const SizedBox(height: 6),
                        _dropdown(_categorias, _categoria, (v) => setState(() => _categoria = v!), Icons.category_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label('Prioridade'),
                        const SizedBox(height: 6),
                        _dropdown(_prioridades, _prioridade, (v) => setState(() => _prioridade = v!), Icons.flag_outlined),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Status (só aparece na edição)
              if (editando) ...[
                label('Status'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _chipStatus('pendente', 'Pendente', Colors.orange),
                    const SizedBox(width: 8),
                    _chipStatus('concluida', 'Concluída', Colors.green),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              // Prazo
              label('Prazo (opcional)'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _escolherData,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFFBBBBBB)),
                      const SizedBox(width: 10),
                      Text(
                        _prazo != null
                            ? '${_prazo!.day.toString().padLeft(2, '0')}/${_prazo!.month.toString().padLeft(2, '0')}/${_prazo!.year}'
                            : 'Selecionar data',
                        style: TextStyle(fontSize: 14, color: _prazo != null ? kEscuro : const Color(0xFFBBBBBB)),
                      ),
                      const Spacer(),
                      if (_prazo != null)
                        GestureDetector(
                          onTap: () => setState(() => _prazo = null),
                          child: const Icon(Icons.close, size: 16, color: Color(0xFFBBBBBB)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: botaoPrincipal(),
                child: Text(editando ? 'Salvar alterações' : 'Criar tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(List<String> itens, String valor, void Function(String?) onChange, IconData icone) {
    return DropdownButtonFormField<String>(
      value: valor,
      decoration: InputDecoration(
        prefixIcon: Icon(icone, size: 18, color: const Color(0xFFBBBBBB)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E5E5))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kAzul, width: 1.5)),
      ),
      items: itens.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChange,
    );
  }

  Widget _chipStatus(String valor, String texto, Color cor) {
    final selecionado = _status == valor;
    return GestureDetector(
      onTap: () => setState(() => _status = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? cor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selecionado ? cor : const Color(0xFFE5E5E5)),
        ),
        child: Text(texto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selecionado ? cor : const Color(0xFF999999))),
      ),
    );
  }
}