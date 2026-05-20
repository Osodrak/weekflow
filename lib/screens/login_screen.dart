import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  bool _esconderSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'user-not-found': 'Nenhuma conta com esse e-mail.',
        'wrong-password': 'Senha incorreta.',
        'invalid-credential': 'E-mail ou senha incorretos.',
        'too-many-requests': 'Muitas tentativas. Aguarde um pouco.',
      };
      if (mounted) _erro(msgs[e.code] ?? 'Erro ao entrar. Tente novamente.');
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
          // Topo colorido com identidade do app
          SizedBox(
            height: altura * 0.38,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.calendar_view_week_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'WeekFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sua semana, organizada.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Card branco que sobe por cima do fundo colorido
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
                      const Text(
                        'Entrar na conta',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bem-vindo de volta!',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 28),

                      // Campo e-mail
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

                      // Campo senha
                      _label('Senha'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _esconderSenha,
                        style: const TextStyle(fontSize: 15),
                        decoration: _inputDecor('••••••••', Icons.lock_outline).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _esconderSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _esconderSenha = !_esconderSenha),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Esqueci a senha alinhado à direita
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                          child: Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF4C5FD5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botão principal
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _carregando
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _entrar,
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
                                child: const Text('Entrar'),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Criar conta
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: RichText(
                            text: TextSpan(
                              text: 'Não tem conta? ',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              children: const [
                                TextSpan(
                                  text: 'Criar agora',
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