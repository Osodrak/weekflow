import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tarefa.dart';
import '../utils/estilos.dart';
import 'login_screen.dart';
import 'tarefa_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Filtra por status: null = todos, 'pendente', 'concluida'
  String? _filtro;

  // Referência para a subcoleção do usuário logado no Firestore
  CollectionReference get _colecao {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('tarefas');
  }

  Future<void> _sair() async {
    final confirmar = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Sair da conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kEscuro)),
            const SizedBox(height: 6),
            const Text('Tem certeza que quer sair do WeekFlow?', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Cancelar', style: TextStyle(color: kEscuro)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Sair'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
    if (confirmar == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  Future<void> _excluir(Tarefa tarefa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir tarefa'),
        content: Text('Deseja excluir "${tarefa.titulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      try {
        await _colecao.doc(tarefa.id).delete();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarefa excluída.'), behavior: SnackBarBehavior.floating));
      } catch (_) {
        if (mounted) mostrarErro(context, 'Erro ao excluir. Tente novamente.');
      }
    }
  }

  void _abrirFormulario([Tarefa? tarefa]) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TarefaFormScreen(tarefa: tarefa)));
  }

  // Cor e ícone de acordo com a prioridade
  Color _corPrioridade(String p) => p == 'Alta' ? Colors.red.shade400 : p == 'Normal' ? Colors.orange.shade400 : Colors.green.shade400;
  Color _corCategoria(String c) {
    const mapa = {'Trabalho': Color(0xFF4C5FD5), 'Estudo': Color(0xFF9B59B6), 'Pessoal': Color(0xFF27AE60), 'Saúde': Color(0xFFE74C3C), 'Geral': Color(0xFF7F8C8D)};
    return mapa[c] ?? kAzul;
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    final nome = email.split('@').first;

    return Scaffold(
      backgroundColor: kFundo,
      body: CustomScrollView(
        slivers: [
          // AppBar com gradiente
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: kAzul,
            elevation: 0,
            actions: [
              IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: _sair),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [kAzul, Color(0xFF7B89F0)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Olá, $nome 👋', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filtros de status
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chipFiltro('Todas', null),
                    const SizedBox(width: 8),
                    _chipFiltro('Pendentes', 'pendente'),
                    const SizedBox(width: 8),
                    _chipFiltro('Concluídas', 'concluida'),
                  ],
                ),
              ),
            ),
          ),

          // Lista de tarefas via StreamBuilder (atualiza em tempo real)
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: _colecao.orderBy('criadoEm', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Padding(padding: EdgeInsets.all(20), child: Text('Erro ao carregar tarefas.'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()));

                var tarefas = snapshot.data!.docs.map((d) => Tarefa.fromDoc(d)).toList();

                // Aplica o filtro de status se selecionado
                if (_filtro != null) tarefas = tarefas.where((t) => t.status == _filtro).toList();

                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header da lista
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tarefas.length} tarefa${tarefas.length != 1 ? 's' : ''}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kEscuro)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: kAzul.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('${tarefas.where((t) => t.status == 'concluida').length} concluídas', style: const TextStyle(fontSize: 12, color: kAzul, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Estado vazio
                      if (tarefas.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Column(children: [
                            Icon(Icons.checklist_rounded, size: 40, color: Colors.grey.shade300),
                            const SizedBox(height: 10),
                            Text('Nenhuma tarefa aqui', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
                            const SizedBox(height: 4),
                            Text('Toque no + para adicionar', style: TextStyle(fontSize: 12, color: Colors.grey.shade300)),
                          ]),
                        ),

                      // Cards de tarefa
                      ...tarefas.map((t) => _cardTarefa(t)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Botão flutuante para criar nova tarefa
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: kAzul,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // Card de cada tarefa na listagem
  Widget _cardTarefa(Tarefa t) {
    final concluida = t.status == 'concluida';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: concluida ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        leading: GestureDetector(
          // Toque no círculo alterna entre pendente e concluída
          onTap: () => _colecao.doc(t.id).update({'status': concluida ? 'pendente' : 'concluida'}),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: concluida ? Colors.green.withOpacity(0.1) : Colors.transparent,
              border: Border.all(color: concluida ? Colors.green : Colors.grey.shade300, width: 2),
            ),
            child: concluida ? const Icon(Icons.check, size: 16, color: Colors.green) : null,
          ),
        ),
        title: Text(
          t.titulo,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: kEscuro, decoration: concluida ? TextDecoration.lineThrough : null),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(t.descricao, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
            const SizedBox(height: 8),
            Row(children: [
              // Badge categoria
              _badge(t.categoria, _corCategoria(t.categoria)),
              const SizedBox(width: 6),
              // Badge prioridade
              _badge(t.prioridade, _corPrioridade(t.prioridade)),
              const SizedBox(width: 6),
              // Data de prazo se houver
              if (t.prazo != null)
                _badge('${t.prazo!.day.toString().padLeft(2, '0')}/${t.prazo!.month.toString().padLeft(2, '0')}', Colors.grey.shade500, Icons.calendar_today_outlined),
            ]),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF999999)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (v) => v == 'editar' ? _abrirFormulario(t) : _excluir(t),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'editar', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 10), Text('Editar')])),
            const PopupMenuItem(value: 'excluir', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 10), Text('Excluir', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  Widget _badge(String texto, Color cor, [IconData? icone]) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: cor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[Icon(icone, size: 10, color: cor), const SizedBox(width: 3)],
            Text(texto, style: TextStyle(fontSize: 11, color: cor, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _chipFiltro(String texto, String? valor) {
    final selecionado = _filtro == valor;
    return GestureDetector(
      onTap: () => setState(() => _filtro = valor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? kAzul : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selecionado ? kAzul : const Color(0xFFE5E5E5)),
        ),
        child: Text(texto, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: selecionado ? Colors.white : const Color(0xFF999999))),
      ),
    );
  }
}