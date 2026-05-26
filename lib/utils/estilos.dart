import 'package:flutter/material.dart';

const kAzul = Color(0xFF4C5FD5);
const kFundo = Color(0xFFF7F8FC);
const kEscuro = Color(0xFF1A1A2E);

// Decoração padrão dos campos de texto usada em todas as telas
InputDecoration inputDecor(String hint, IconData icone) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
      prefixIcon: Icon(icone, size: 18, color: const Color(0xFFBBBBBB)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _borda(),
      enabledBorder: _borda(),
      focusedBorder: _borda(color: kAzul, width: 1.5),
      errorBorder: _borda(color: Colors.redAccent),
      focusedErrorBorder: _borda(color: Colors.redAccent, width: 1.5),
    );

OutlineInputBorder _borda({Color color = const Color(0xFFE5E5E5), double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

// Estilo padrão do botão principal
ButtonStyle botaoPrincipal() => ElevatedButton.styleFrom(
      backgroundColor: kAzul,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );

// Label acima dos campos
Widget label(String texto) => Text(
      texto,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kEscuro),
    );

// Ícone no topo das telas
Widget iconeHeader(IconData icone, {Color cor = kAzul, Color? fundo}) => Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: fundo ?? kAzul.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icone, color: cor, size: 26),
    );

// Snackbar de erro
void mostrarErro(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: Colors.red.shade800,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));
}

// Rodapé de navegação entre telas (ex: "Não tem conta? Criar agora")
Widget rodapeNavegacao(String texto, String acao, VoidCallback onTap) => GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          text: texto,
          style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          children: [
            TextSpan(
              text: acao,
              style: const TextStyle(color: kAzul, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );

// Topo colorido reutilizado no login e cadastro
Widget topoColorido({required double altura, required Widget filho}) => Container(
      height: altura,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kAzul, Color(0xFF7B89F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: filho,
    );

// Card branco arredondado no topo que fica sobre o fundo colorido
Widget cardBranco({required Widget filho}) => Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: kFundo,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: filho,
        ),
      ),
    );