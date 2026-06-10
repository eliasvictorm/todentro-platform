import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _pink = Color(0xFFD4006A);
  final _nameCtrl = TextEditingController();
  bool _editing = false;
  bool _saving  = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile(_nameCtrl.text.trim());
      if (!mounted) return;
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!'), backgroundColor: Colors.green));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar.'), backgroundColor: _pink));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: ()=>Navigator.pop(context,true),
              style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white),
              child: const Text('Sair')),
        ],
      ),
    );
    if (ok==true && mounted) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(children: [
                const Text('TôDentro!',
                    style: TextStyle(color: _pink, fontSize: 20, fontWeight: FontWeight.w900)),
                const Spacer(),
                TextButton(
                    onPressed: _logout,
                    child: const Text('Sair', style: TextStyle(color: Colors.grey))),
              ]),
            ),

            const SizedBox(height: 24),

            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: _pink.withOpacity(0.15),
                  child: Text(
                    auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
                    style: const TextStyle(color: _pink, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => setState(() { _editing = true; _nameCtrl.text = auth.userName; }),
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: _pink, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_editing) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _nameCtrl, autofocus: true, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    decoration: const InputDecoration(hintText: 'Seu nome'))),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:_pink))
                        : const Icon(Icons.check_circle, color: _pink, size: 28)),
                  IconButton(
                    onPressed: () => setState(() => _editing = false),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.grey, size: 28)),
                ]),
              ),
            ] else ...[
              Text(auth.userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(auth.userEmail, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _statCard('${eventProvider.events.length}', 'Rolês criados'),
                const SizedBox(width: 12),
                _statCard(
                    '${eventProvider.events.fold(0, (s, e) => s + e.participantCount)}',
                    'Total convidados'),
                const SizedBox(width: 12),
                _statCard(
                    '${eventProvider.events.where((e) => _isToday(e.date)).length}',
                    'Rolês hoje'),
              ]),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                _menuItem(Icons.event_outlined, 'Meus eventos', () {}),
                _menuItem(Icons.people_outline, 'Meus participantes', () {}),
                _menuItem(Icons.notifications_outlined, 'Notificações', () {}),
                _menuItem(Icons.help_outline, 'Ajuda', () {}),
                _menuItem(Icons.privacy_tip_outlined, 'Privacidade', () {}),
                _menuItem(Icons.logout, 'Sair da conta', _logout, color: _pink),
              ]),
            ),

            const SizedBox(height: 40),
            Text('TôDentro v1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _pink)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color ?? Colors.black54, size: 22),
          title: Text(label,
              style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500, fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ),
      );

  bool _isToday(String date) {
    try {
      final d = DateTime.parse(date);
      final now = DateTime.now();
      return d.year==now.year && d.month==now.month && d.day==now.day;
    } catch (_) { return false; }
  }
}
