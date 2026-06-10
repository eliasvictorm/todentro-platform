import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const Color _pink = Color(0xFFD4006A);
  late TabController _tabs;

  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl  = TextEditingController();

  bool _loading = false;
  bool _obscureLogin = true;
  bool _obscureReg   = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: _pink),
    );
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      _snack('Preencha e-mail e senha.');
      return;
    }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().login(
            _emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (_) {
      if (mounted) _snack('E-mail ou senha incorretos.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Informe seu nome.'); return; }
    if (_regEmailCtrl.text.trim().isEmpty) { _snack('Informe o e-mail.'); return; }
    if (_regPassCtrl.text.length < 6) { _snack('Senha mínimo 6 caracteres.'); return; }
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().register(
            _nameCtrl.text.trim(), _regEmailCtrl.text.trim(), _regPassCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (mounted) _snack('Erro ao criar conta. Tente outro e-mail.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Pink header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: 260,
            decoration: const BoxDecoration(
              color: _pink,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40, top: -40,
                  child: Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.10)),
                  ),
                ),
                Positioned(
                  left: -30, bottom: 20,
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07)),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TôDentro!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'organize seus rolês 🎉',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Form area ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2),
                      children: [
                        TextSpan(text: 'vamos\nplanejar\nseu '),
                        TextSpan(
                          text: 'rolê?',
                          style: TextStyle(color: _pink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicator: BoxDecoration(
                          color: _pink, borderRadius: BorderRadius.circular(10)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      dividerColor: Colors.transparent,
                      tabs: const [Tab(text: 'Entrar'), Tab(text: 'Criar conta')],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 280,
                    child: TabBarView(
                      controller: _tabs,
                      children: [_buildLoginForm(), _buildRegisterForm()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        _field(_emailCtrl, 'E-mail', Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_passCtrl, 'Senha', Icons.lock_outline,
            obscure: _obscureLogin,
            suffix: IconButton(
              icon: Icon(_obscureLogin ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
              onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
            )),
        const SizedBox(height: 20),
        _primaryBtn(_loading ? null : _login, 'Fazer Login'),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Não tem conta? ', style: TextStyle(color: Colors.grey)),
          GestureDetector(
            onTap: () => _tabs.animateTo(1),
            child: const Text('Criar', style: TextStyle(color: _pink, fontWeight: FontWeight.bold)),
          ),
        ]),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _field(_nameCtrl, 'Nome completo', Icons.person_outline),
        const SizedBox(height: 10),
        _field(_regEmailCtrl, 'E-mail', Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 10),
        _field(_regPassCtrl, 'Senha (mín. 6 caracteres)', Icons.lock_outline,
            obscure: _obscureReg,
            suffix: IconButton(
              icon: Icon(_obscureReg ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
              onPressed: () => setState(() => _obscureReg = !_obscureReg),
            )),
        const SizedBox(height: 20),
        _primaryBtn(_loading ? null : _register, 'Criar Conta'),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _pink, width: 1.5)),
        labelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _primaryBtn(VoidCallback? onTap, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _pink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _pink.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
