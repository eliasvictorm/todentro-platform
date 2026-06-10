import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';

class GastosScreen extends StatelessWidget {
  const GastosScreen({super.key});
  static const Color _pink = Color(0xFFD4006A);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: const Text('TôDentro!',
                style: TextStyle(
                    color: _pink, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Débitos',
                style:
                    TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: Consumer<EventProvider>(
              builder: (_, provider, __) {
                if (provider.loading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _pink));
                }
                if (provider.events.isEmpty) {
                  return _buildEmpty();
                }
                return RefreshIndicator(
                  color: _pink,
                  onRefresh: () => provider.loadEvents(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: provider.events.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (_, i) =>
                        _GastoCard(event: provider.events[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmpty() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('💸', style: TextStyle(fontSize: 56)),
            SizedBox(height: 12),
            Text('Sem débitos por aqui!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54)),
            SizedBox(height: 8),
            Text('Crie um rolê e adicione participantes',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}

class _GastoCard extends StatefulWidget {
  final Event event;
  const _GastoCard({required this.event});

  @override
  State<_GastoCard> createState() => _GastoCardState();
}

class _GastoCardState extends State<_GastoCard> {
  static const Color _pink = Color(0xFFD4006A);
  final ApiService _api = ApiService();
  List<Participant> _participants = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (widget.event.id != null) {
        final list = await _api.getParticipants(widget.event.id!);
        if (mounted) setState(() => _participants = list);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _costPerPerson => _participants.isEmpty
      ? 0
      : (widget.event.maxParticipants * 10.0) / _participants.length;

  bool _isToday(String date) {
    try {
      final d = DateTime.parse(date);
      final now = DateTime.now();
      return d.year == now.year &&
          d.month == now.month &&
          d.day == now.day;
    } catch (_) {
      return false;
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

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final hasCover =
        event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty;
    final allPaid = _participants.isNotEmpty &&
        _participants.every((p) => p.paid);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            // Cover
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: hasCover
                      ? (event.coverImageUrl!.startsWith('/')
                          ? Image.file(File(event.coverImageUrl!),
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : Image.network(event.coverImageUrl!,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _gradCover(event)))
                      : _gradCover(event),
                ),
                if (_isToday(event.date))
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: _pink,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('É HOJE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                      '📅 ${_fmtDate(event.date)}  •  📍 ${event.location}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _pink))
                          : Text(
                              _participants.isEmpty
                                  ? 'Sem participantes'
                                  : 'R\$ ${_costPerPerson.toStringAsFixed(2)} por pessoa',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: allPaid
                              ? Colors.green.shade50
                              : _pink.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: allPaid
                                  ? Colors.green.shade200
                                  : _pink.withOpacity(0.25)),
                        ),
                        child: Center(
                          child: Text(
                            allPaid
                                ? '✓  Todos pagaram'
                                : 'Pagamentos pendentes',
                            style: TextStyle(
                                color: allPaid
                                    ? Colors.green.shade700
                                    : _pink,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '👥 ${_loading ? '...' : _participants.length.toString()}',
                        style:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gradCover(Event event) => Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        _catColor(event.category).withOpacity(0.8),
        _catColor(event.category)
      ])),
      child: Center(
          child: Text(_emoji(event.category),
              style: const TextStyle(fontSize: 40))));

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        event: widget.event,
        participants: _participants,
        costPerPerson: _costPerPerson,
        onTogglePaid: (index, paid) async {
          final p = _participants[index];
          if (widget.event.id == null || p.id == null) return;
          try {
            await _api.togglePaid(widget.event.id!, p.id!, paid);
            if (mounted)
              setState(() => _participants[index].paid = paid);
          } catch (_) {}
        },
      ),
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final Event event;
  final List<Participant> participants;
  final double costPerPerson;
  final Future<void> Function(int index, bool paid) onTogglePaid;

  const _DetailSheet({
    required this.event,
    required this.participants,
    required this.costPerPerson,
    required this.onTogglePaid,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  static const Color _pink = Color(0xFFD4006A);
  late List<Participant> _parts;

  @override
  void initState() {
    super.initState();
    _parts = List<Participant>.from(widget.participants);
  }

  double get _total => widget.event.maxParticipants * 10.0;
  int get _paidCount => _parts.where((p) => p.paid).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _pink, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text(widget.event.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const Text('TOTAL DO ROLÊ',
                  style: TextStyle(color: Colors.white60, fontSize: 11)),
              Text('R\$ ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(children: [
                  const Text('SUA PARTE',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 10)),
                  Text(
                    widget.costPerPerson > 0
                        ? 'R\$ ${widget.costPerPerson.toStringAsFixed(2)}'
                        : 'R\$ 0,00',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ])),
                Container(
                    width: 1, height: 36, color: Colors.white30),
                Expanded(
                    child: Column(children: [
                  const Text('PAGAMENTOS',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 10)),
                  Text('$_paidCount/${_parts.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ])),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$_paidCount de ${_parts.length} pagaram',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      Text(
                          '${_parts.isEmpty ? 0 : (_paidCount * 100 / _parts.length).round()}%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _pink)),
                    ]),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _parts.isEmpty
                        ? 0
                        : _paidCount / _parts.length,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(_pink),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _parts.isEmpty
                ? const Center(
                    child: Text('Nenhum participante ainda.',
                        style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _parts.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = _parts[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(children: [
                          CircleAvatar(
                            backgroundColor: _pink.withOpacity(0.15),
                            radius: 20,
                            child: Text(
                                p.name.isNotEmpty
                                    ? p.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: _pink,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(
                                    'R\$ ${widget.costPerPerson.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12)),
                              ])),
                          GestureDetector(
                            onTap: () async {
                              final newPaid = !p.paid;
                              setState(() => _parts[i].paid = newPaid);
                              await widget.onTogglePaid(i, newPaid);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: p.paid
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: p.paid
                                        ? Colors.green.shade200
                                        : Colors.orange.shade200),
                              ),
                              child: Text(
                                p.paid ? 'PAGO' : 'Pendente',
                                style: TextStyle(
                                  color: p.paid
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
