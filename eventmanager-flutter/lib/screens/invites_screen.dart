import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class InvitesScreen extends StatefulWidget {
  const InvitesScreen({super.key});

  @override
  State<InvitesScreen> createState() => _InvitesScreenState();
}

class _InvitesScreenState extends State<InvitesScreen>
    with SingleTickerProviderStateMixin {
  static const Color _pink = Color(0xFFD4006A);
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InviteProvider>().loadInvites();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TôDentro!',
                    style: TextStyle(
                        color: _pink, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                const Text('Convites',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabs,
                  labelColor: _pink,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: _pink,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Pendentes'),
                    Tab(text: 'Respondidos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<InviteProvider>(
              builder: (_, provider, __) {
                if (provider.loading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _pink));
                }
                return TabBarView(
                  controller: _tabs,
                  children: [
                    _buildList(
                      provider.invites
                          .where((i) => i.status == 'PENDING')
                          .toList(),
                      isPending: true,
                    ),
                    _buildList(
                      provider.invites
                          .where((i) => i.status != 'PENDING')
                          .toList(),
                      isPending: false,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Invite> invites, {required bool isPending}) {
    if (invites.isEmpty) {
      return RefreshIndicator(
        color: _pink,
        onRefresh: () => context.read<InviteProvider>().loadInvites(),
        child: ListView(children: [
          SizedBox(
            height: 300,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isPending ? '📬' : '✅',
                      style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    isPending
                        ? 'Nenhum convite pendente'
                        : 'Nenhum convite respondido',
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ]),
      );
    }

    return RefreshIndicator(
      color: _pink,
      onRefresh: () => context.read<InviteProvider>().loadInvites(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: invites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
            _buildCard(invites[i], isPending: isPending),
      ),
    );
  }

  Widget _buildCard(Invite invite, {required bool isPending}) {
    final isAccepted = invite.status == 'ACCEPTED';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          // Cover strip
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  _catColor(invite.eventCategory).withOpacity(0.7),
                  _catColor(invite.eventCategory),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(_emoji(invite.eventCategory),
                      style: const TextStyle(fontSize: 32)),
                ),
                if (!isPending)
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAccepted
                            ? Colors.green
                            : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAccepted ? '✓ Aceito' : '✗ Recusado',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.eventName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Convidado por ${invite.inviterName}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                      '${_fmtDate(invite.eventDate)}  •  ${invite.eventTime.substring(0, 5)}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(invite.eventLocation,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _respond(invite, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Recusar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _respond(invite, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Aceitar',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(Invite invite, bool accept) async {
    try {
      await context.read<InviteProvider>().respond(invite.id, accept);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            accept ? 'Você confirmou presença! 🎉' : 'Convite recusado.'),
        backgroundColor: accept ? Colors.green : Colors.grey,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: _pink));
    }
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return d;
    }
  }

  Color _catColor(String cat) => switch (cat) {
        'Show' => const Color(0xFF8B1A8B),
        'Conferência' => const Color(0xFF1A4B8B),
        'Esporte' => const Color(0xFF1A8B4B),
        'Workshop' => const Color(0xFF8B5A1A),
        _ => const Color(0xFF8B1A4B),
      };

  String _emoji(String cat) => switch (cat) {
        'Show' => '🎵',
        'Esporte' => '⚽',
        'Workshop' => '🛠️',
        'Conferência' => '🎤',
        _ => '🎉',
      };
}
