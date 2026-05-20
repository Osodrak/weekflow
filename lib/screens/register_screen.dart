import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _carregando = false;
  bool _esconderSenha = true;
  bool _esconderConfirmar = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'email-already-in-use': 'Esse e-mail já está cadastrado.',
        'weak-password': 'Senha muito fraca. Use pelo menos 6 caracteres.',
        'invalid-email': 'E-mail inválido.',
      };
      if (mounted) _erro(msgs[e.code] ?? 'Erro ao criar conta.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _erro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade800,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF4C5FD5),
      body: Column(
        children: [
          // Topo com botão de voltar e título
          SizedBox(
            height: altura * 0.30,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        'Criar conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        'Comece a organizar sua semana agora',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),

          // Card com os campos
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('E-mail'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 15),
                        decoration: _inputDecor('seu@email.com', Icons.email_outlined),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Informe o e-mail.';
                          if (!v.contains('@')) return 'E-mail inválido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      _label('Senha'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _esconderSenha,
                        style: const TextStyle(fontSize: 15),
                        decoration: _inputDecor('mínimo 6 caracteres', Icons.lock_outline).copyWith(
                          suffixIcon: _toggleSenha(
                            _esconderSenha,
                            () => setState(() => _esconderSenha = !_esconderSenha),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe uma senha.';
                          if (v.length < 6) return 'Mínimo de 6 caracteres.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      _label('Confirmar senha'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmarController,
                        obscureText: _esconderConfirmar,
                        style: const TextStyle(fontSize: 15),
                        decoration: _inputDecor('repita a senha', Icons.lock_outline).copyWith(
                          suffixIcon: _toggleSenha(
                            _esconderConfirmar,
                            () => setState(() => _esconderConfirmar = !_esconderConfirmar),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirme a senha.';
                          if (v != _senhaController.text) return 'As senhas não coincidem.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _carregando
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _cadastrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4C5FD5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Criar conta'),
                              ),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Já tem conta? ',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              children: const [
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(
                                    color: Color(0xFF4C5FD5),
                                    fontWeight: FontWeight.w600,
                                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _label(String texto) => Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      );

  Widget _toggleSenha(bool esconder, VoidCallback onPressed) => IconButton(
        icon: Icon(
          esconder ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onPressed: onPressed,
      );

  InputDecoration _inputDecor(String hint, IconData icone) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icone, size: 18, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4C5FD5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
}