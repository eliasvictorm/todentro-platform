import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import 'invite_users_screen.dart';

class CreateRoleScreen extends StatefulWidget {
  final Event? eventToEdit;
  const CreateRoleScreen({super.key, this.eventToEdit});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  static const Color _pink = Color(0xFFD4006A);

  final _nameCtrl     = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxCtrl      = TextEditingController(text: '10');

  DateTime? _date;
  TimeOfDay? _time;
  String _category = 'Social';
  final Set<String> _vibes = {};
  bool _loading = false;
  File? _coverImage;
  String? _coverImageUrl;

  static const _categories = ['Conferência','Workshop','Show','Esporte','Social','Outro'];
  static const _vibeOptions = [
    'Balada','Noitada','Jitter','Underground','Aconchegante',
    'Divertido','Elegante','Casual','Tanderinha','Intimista',
    'Fitness','Jogos','Artístico','Sem limites','Natureza',
  ];

  bool get _isEditing => widget.eventToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final e = widget.eventToEdit!;
      _nameCtrl.text     = e.name;
      _descCtrl.text     = e.description ?? '';
      _locationCtrl.text = e.location;
      _maxCtrl.text      = e.maxParticipants.toString();
      _category          = e.category;
      _coverImageUrl     = e.coverImageUrl;
      final dp = e.date.split('-');
      if (dp.length == 3) _date = DateTime(int.parse(dp[0]), int.parse(dp[1]), int.parse(dp[2]));
      final tp = e.time.split(':');
      if (tp.length >= 2) _time = TimeOfDay(hour: int.parse(tp[0]), minute: int.parse(tp[1]));
      if (e.description != null) {
        for (final v in _vibeOptions) { if (e.description!.contains(v)) _vibes.add(v); }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose();
    _locationCtrl.dispose(); _maxCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? _pink : Colors.green));

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top:10), width:40, height:4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        ListTile(leading: const Icon(Icons.photo_camera_outlined, color: _pink),
            title: const Text('Tirar foto'),
            onTap: () async { Navigator.pop(context); await _getImage(ImageSource.camera); }),
        ListTile(leading: const Icon(Icons.photo_library_outlined, color: _pink),
            title: const Text('Escolher da galeria'),
            onTap: () async { Navigator.pop(context); await _getImage(ImageSource.gallery); }),
        if (_coverImage != null || _coverImageUrl != null)
          ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Remover foto', style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(context); setState(() { _coverImage = null; _coverImageUrl = null; }); }),
        const SizedBox(height: 8),
      ])),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (picked != null && mounted) setState(() { _coverImage = File(picked.path); _coverImageUrl = null; });
    } catch (_) {
      if (!mounted) return;
      _snack('Erro ao selecionar imagem.');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context, initialDate: _date ?? now, firstDate: now,
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _pink, onPrimary: Colors.white)),
          child: child!),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context, initialTime: _time ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _pink, onPrimary: Colors.white)),
          child: child!),
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final name     = _nameCtrl.text.trim();
    final location = _locationCtrl.text.trim();
    final max      = int.tryParse(_maxCtrl.text.trim());
    if (name.isEmpty)           { _snack('Dê um nome ao rolê!'); return; }
    if (_date == null)          { _snack('Escolha a data!'); return; }
    if (_time == null)          { _snack('Escolha o horário!'); return; }
    if (location.isEmpty)       { _snack('Informe o local!'); return; }
    if (max == null || max < 1) { _snack('Número máximo inválido!'); return; }

    setState(() => _loading = true);
    try {
      final dateStr = '${_date!.year}-${_date!.month.toString().padLeft(2,'0')}-${_date!.day.toString().padLeft(2,'0')}';
      final timeStr = '${_time!.hour.toString().padLeft(2,'0')}:${_time!.minute.toString().padLeft(2,'0')}';
      String? imageUrl = _coverImageUrl;
      if (_coverImage != null) imageUrl = _coverImage!.path;

      final event = Event(
        id: widget.eventToEdit?.id,
        name: name,
        description: _vibes.isNotEmpty ? _vibes.join(', ') : (_descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()),
        date: dateStr, time: timeStr, location: location,
        maxParticipants: max, category: _category, coverImageUrl: imageUrl,
      );

      final provider = context.read<EventProvider>();
      if (_isEditing) {
        await provider.updateEvent(widget.eventToEdit!.id!, event);
        if (!mounted) return;
        _snack('Rolê atualizado! ✅', error: false);
        Navigator.pop(context);
      } else {
        final saved = await provider.createEvent(event);
        if (!mounted) return;
        _resetForm();
        _showInvitePrompt(saved);
      }
    } catch (e) {
      if (mounted) _snack('Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _nameCtrl.clear(); _descCtrl.clear(); _locationCtrl.clear(); _maxCtrl.text = '10';
    setState(() { _date = null; _time = null; _vibes.clear(); _category = 'Social'; _coverImage = null; _coverImageUrl = null; });
  }

  void _showInvitePrompt(Event event) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Rolê criado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Que tal chamar a galera agora?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => InviteUsersScreen(event: event))); },
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Convidar galera', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          )),
          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Depois', style: TextStyle(color: Colors.grey))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(20,16,20,16),
          child: const Row(children: [Text('TôDentro!', style: TextStyle(color: _pink, fontSize: 20, fontWeight: FontWeight.w900))])),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20,20,20,100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_isEditing ? 'Editar Rolê' : 'Criar Rolê', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          // Cover + name
          GestureDetector(onTap: _pickImage, child: Container(
            height: 160, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _pink.withOpacity(0.3), width: 1.5)),
            child: Stack(children: [
              if (_coverImage != null) Positioned.fill(child: Image.file(_coverImage!, fit: BoxFit.cover))
              else if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
                Positioned.fill(child: Image.network(_coverImageUrl!, fit: BoxFit.cover, errorBuilder:(_,__,___)=>_coverBg()))
              else _coverBg(),
              if (_coverImage != null || (_coverImageUrl != null && _coverImageUrl!.isNotEmpty))
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.25))),
              Positioned(top:12, right:12, child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18))),
              Positioned(bottom:12, left:12, right:12, child: TextField(controller: _nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: InputDecoration(hintText: '✏️  Nome do Rolê *',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  filled: true, fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), isDense: true))),
            ])),
          ),
          const SizedBox(height: 20),

          Text('Categoria', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _category, isExpanded: true,
              onChanged: (v) { if (v != null) setState(() => _category = v); },
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList()))),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _pickerBox(_date != null ? '${_date!.day.toString().padLeft(2,'0')}/${_date!.month.toString().padLeft(2,'0')}/${_date!.year}' : 'Data *', Icons.calendar_today_outlined, _pickDate, hasValue: _date != null)),
            const SizedBox(width: 10),
            Expanded(child: _pickerBox(_time != null ? '${_time!.hour.toString().padLeft(2,'0')}:${_time!.minute.toString().padLeft(2,'0')}' : 'Hora *', Icons.access_time_outlined, _pickTime, hasValue: _time != null)),
          ]),
          const SizedBox(height: 10),
          _textField(_locationCtrl, '📍  Local *', Icons.location_on_outlined),
          const SizedBox(height: 10),
          _textField(_maxCtrl, '👥  Máx. de pessoas', Icons.people_outline, inputType: TextInputType.number),
          const SizedBox(height: 16),
          _textField(_descCtrl, 'Descrição (opcional)', Icons.notes_outlined, maxLines: 3),
          const SizedBox(height: 24),

          const Text('Vibe do Rolê', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _vibeOptions.map((v) {
            final active = _vibes.contains(v);
            return GestureDetector(onTap: () => setState(() => active ? _vibes.remove(v) : _vibes.add(v)),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: active ? _pink : Colors.white, borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? _pink : Colors.grey.shade300)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (active) ...[const Icon(Icons.check, size: 12, color: Colors.white), const SizedBox(width: 4)],
                  Text(v, style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 12,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                ])));
          }).toList()),
          const SizedBox(height: 32),

          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white,
                disabledBackgroundColor: _pink.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 18)),
            child: _loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEditing ? 'Salvar alterações' : 'Agendar Rolê', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        ]),
      )),
    ]));
  }

  Widget _coverBg() => Container(color: _pink.withOpacity(0.08),
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.add_photo_alternate_outlined, color: _pink.withOpacity(0.5), size: 36),
      const SizedBox(height: 6),
      Text('Adicionar foto de capa', style: TextStyle(color: _pink.withOpacity(0.6), fontSize: 12)),
    ])));

  Widget _pickerBox(String label, IconData icon, VoidCallback onTap, {bool hasValue = false}) =>
      GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hasValue ? _pink.withOpacity(0.5) : Colors.grey.shade200, width: hasValue ? 1.5 : 1)),
        child: Row(children: [
          Icon(icon, size: 16, color: hasValue ? _pink : Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: hasValue ? Colors.black87 : Colors.grey, fontSize: 13,
              fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal))),
        ])));

  Widget _textField(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) =>
      TextField(controller: ctrl, maxLines: maxLines, keyboardType: inputType,
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey, size: 18), filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _pink, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)));
}
