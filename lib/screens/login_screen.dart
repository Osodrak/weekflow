import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/estilos.dart';
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
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _carregando = false;
  bool _esconder = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _senhaCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'user-not-found': 'Nenhuma conta com esse e-mail.',
        'wrong-password': 'Senha incorreta.',
        'invalid-credential': 'E-mail ou senha incorretos.',
        'too-many-requests': 'Muitas tentativas. Aguarde um pouco.',
      };
      if (mounted) mostrarErro(context, msgs[e.code] ?? 'Erro ao entrar.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAzul,
      body: Column(
        children: [
          // Topo colorido com logo centralizado
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.calendar_view_week_rounded, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'WeekFlow',
                      style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sua semana, organizada.',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Card branco com formulário
          cardBranco(
            filho: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Entrar na conta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kEscuro)),
                  const SizedBox(height: 4),
                  const Text('Bem-vindo de volta!', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
                  const SizedBox(height: 28),

                  label('E-mail'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecor('seu@email.com', Icons.email_outlined),
                    validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido.' : null,
                  ),
                  const SizedBox(height: 18),

                  label('Senha'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _senhaCtrl,
                    obscureText: _esconder,
                    decoration: inputDecor('••••••••', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_esconder ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: const Color(0xFFBBBBBB)),
                        onPressed: () => setState(() => _esconder = !_esconder),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha.' : null,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Esqueci minha senha', style: TextStyle(fontSize: 13, color: kAzul, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _carregando
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(onPressed: _entrar, style: botaoPrincipal(), child: const Text('Entrar')),
                  const SizedBox(height: 24),

                  Center(child: rodapeNavegacao('Não tem conta? ', 'Criar agora', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  })),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}