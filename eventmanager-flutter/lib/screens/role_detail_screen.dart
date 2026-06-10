import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'create_role_screen.dart';
import 'invite_users_screen.dart';

class RoleDetailScreen extends StatefulWidget {
  final Event event;
  const RoleDetailScreen({super.key, required this.event});
  @override State<RoleDetailScreen> createState() => _RoleDetailScreenState();
}

class _RoleDetailScreenState extends State<RoleDetailScreen> {
  static const Color _pink = Color(0xFFD4006A);
  final ApiService _api = ApiService();
  final TextEditingController _taskCtrl = TextEditingController();
  bool _toDentro = true;
  bool _loadingPart = true;
  List<Participant> _participants = [];
  final List<ChecklistItem> _checklist = [];
  late Event _event;

  @override
  void initState() { super.initState(); _event = widget.event; _loadParticipants(); }
  @override
  void dispose() { _taskCtrl.dispose(); super.dispose(); }

  Future<void> _loadParticipants() async {
    if (!mounted) return;
    setState(() => _loadingPart = true);
    try {
      if (_event.id != null) {
        final list = await _api.getParticipants(_event.id!);
        if (mounted) setState(() => _participants = list);
      }
    } catch (_) {} finally { if (mounted) setState(() => _loadingPart = false); }
  }

  Future<void> _showAddSheet() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showModalBottomSheet<bool>(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Adicionar participante', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextFormField(controller: nameCtrl, decoration: _dec('Nome *'), validator: (v) => (v==null||v.trim().isEmpty)?'Obrigatório':null),
          const SizedBox(height: 10),
          TextFormField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _dec('E-mail *'), validator: (v) => (v==null||v.trim().isEmpty)?'Obrigatório':null),
          const SizedBox(height: 10),
          TextFormField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: _dec('Telefone (opcional)')),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(ctx, true); },
            style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)))),
        ])),
      ),
    );
    if (confirmed == true && _event.id != null && mounted) {
      try {
        final p = Participant(name: nameCtrl.text.trim(), email: emailCtrl.text.trim(),
            phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim());
        await _api.addParticipant(_event.id!, p);
        await _loadParticipants();
      } catch (e) { if (mounted) _snack('Erro: $e'); }
    }
  }

  Future<void> _removeParticipant(Participant p) async {
    if (_event.id == null || p.id == null) return;
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Remover participante'), content: Text('Remover ${p.name}?'),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancelar')),
        TextButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('Remover',style:TextStyle(color:Colors.red)))],
    ));
    if (ok==true && mounted) {
      try { await _api.removeParticipant(_event.id!, p.id!); await _loadParticipants(); }
      catch (e) { if (mounted) _snack('Erro: $e'); }
    }
  }

  Future<void> _togglePaid(Participant p, int index) async {
    if (_event.id == null || p.id == null) return;
    try { await _api.togglePaid(_event.id!, p.id!, !p.paid); setState(() => _participants[index].paid = !p.paid); }
    catch (_) {}
  }

  void _showAddChecklist() {
    _taskCtrl.clear();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Novo item'), content: TextField(controller: _taskCtrl, autofocus: true, decoration: const InputDecoration(hintText: 'Ex: Levar refrigerante')),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () {
          if (_taskCtrl.text.trim().isNotEmpty) setState(() => _checklist.add(ChecklistItem(id: DateTime.now().millisecondsSinceEpoch.toString(), task: _taskCtrl.text.trim())));
          Navigator.pop(context);
        }, style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white), child: const Text('Adicionar')),
      ],
    ));
  }

  Future<void> _deleteEvent() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Excluir rolê'), content: Text('Excluir "${_event.name}"? Esta ação não pode ser desfeita.'),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('Cancelar')),
        ElevatedButton(onPressed: ()=>Navigator.pop(context,true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('Excluir'))],
    ));
    if (ok==true && _event.id!=null && mounted) {
      try { await _api.deleteEvent(_event.id!); if (!mounted) return; Navigator.pop(context); }
      catch (e) { if (mounted) _snack('Erro ao excluir: $e'); }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _pink));

  InputDecoration _dec(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: const Color(0xFFF5F5F5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _pink, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12));

  String _fmtDate(String d) { try { final dt=DateTime.parse(d); return '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}'; } catch(_){return d;} }
  String _emoji(String cat) => switch(cat){'Show'=>'🎵','Esporte'=>'⚽','Workshop'=>'🛠️','Conferência'=>'🎤',_=>'🎉'};

  @override
  Widget build(BuildContext context) {
    final partCount = _participants.length;
    final costPerPerson = partCount > 0 ? (_event.maxParticipants * 10.0) / partCount : 0.0;
    final hasCover = _event.coverImageUrl != null && _event.coverImageUrl!.isNotEmpty;

    return Scaffold(backgroundColor: const Color(0xFFF5F5F5), body: CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 240, pinned: true, backgroundColor: _pink,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: ()=>Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_outlined, color: Colors.white), tooltip: 'Convidar',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InviteUsersScreen(event: _event)))),
          PopupMenuButton<String>(icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (v) {
              if (v=='edit') Navigator.push(context, MaterialPageRoute(builder:(_)=>CreateRoleScreen(eventToEdit: _event)));
              else if (v=='delete') _deleteEvent();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value:'edit',child:Row(children:[Icon(Icons.edit_outlined,size:18),SizedBox(width:8),Text('Editar')])),
              const PopupMenuItem(value:'delete',child:Row(children:[Icon(Icons.delete_outline,size:18,color:Colors.red),SizedBox(width:8),Text('Excluir',style:TextStyle(color:Colors.red))])),
            ]),
        ],
        flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [
          if (hasCover) _event.coverImageUrl!.startsWith('/') ? Image.file(File(_event.coverImageUrl!), fit: BoxFit.cover)
              : Image.network(_event.coverImageUrl!, fit: BoxFit.cover, errorBuilder:(_,__,___)=>_heroGrad())
          else _heroGrad(),
          Container(decoration: BoxDecoration(gradient: LinearGradient(colors:[Colors.transparent, _pink.withOpacity(0.85)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          Positioned(bottom:16, left:16, right:16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_event.name, style: const TextStyle(color:Colors.white, fontSize:22, fontWeight:FontWeight.w900), maxLines:2, overflow:TextOverflow.ellipsis),
            const SizedBox(height:4),
            Row(children:[const Icon(Icons.calendar_today_outlined, color:Colors.white70, size:13), const SizedBox(width:4),
              Text('${_fmtDate(_event.date)}  •  ${_event.time.substring(0,5)}', style: const TextStyle(color:Colors.white70, fontSize:12))]),
          ])),
        ]))),

      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Toggle
        Container(decoration:BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(16),
            boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.06),blurRadius:10)]),
          child:Row(children:[_toggle('TÔ DENTRO',true),_toggle('TÔ FORA',false)])),
        const SizedBox(height:24),

        // Checklist
        const Text('Checklist do Rolê', style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
        const SizedBox(height:12),
        Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),
            boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:8)]),
          child:Column(children:[
            if(_checklist.isEmpty) const Padding(padding:EdgeInsets.symmetric(vertical:20,horizontal:16),
                child:Text('Nenhum item ainda. Adicione abaixo!',style:TextStyle(color:Colors.grey))),
            ..._checklist.asMap().entries.map((e)=>_checklistTile(e.key,e.value)),
            ListTile(onTap:_showAddChecklist,
              leading:Container(width:34,height:34,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.grey.shade300)),
                  child:const Icon(Icons.add,color:Colors.grey,size:18)),
              title:const Text('Adicionar mais itens',style:TextStyle(color:Colors.grey,fontSize:14))),
          ])),
        const SizedBox(height:20),

        // Cost
        Container(padding:const EdgeInsets.all(18),
          decoration:BoxDecoration(color:_pink.withOpacity(0.08),borderRadius:BorderRadius.circular(16),border:Border.all(color:_pink.withOpacity(0.2))),
          child:Row(children:[
            const Icon(Icons.account_balance_wallet_outlined,color:_pink,size:28), const SizedBox(width:14),
            Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Text(partCount>0?'R\$ ${costPerPerson.toStringAsFixed(2)}':'Sem participantes',
                  style:const TextStyle(fontSize:20,fontWeight:FontWeight.w900,color:_pink)),
              const Text('Custo estimado por pessoa',style:TextStyle(color:Colors.grey,fontSize:12)),
            ]),
          ])),
        const SizedBox(height:20),

        // Participants header
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          Text('$partCount CONFIRMADOS',style:const TextStyle(fontSize:15,fontWeight:FontWeight.w800)),
          Row(children:[
            TextButton.icon(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>InviteUsersScreen(event:_event))),
                icon:const Icon(Icons.mail_outline,color:_pink,size:18),label:const Text('Convidar',style:TextStyle(color:_pink,fontSize:13))),
            TextButton.icon(onPressed:_showAddSheet,
                icon:const Icon(Icons.add,color:_pink,size:18),label:const Text('Adicionar',style:TextStyle(color:_pink,fontSize:13))),
          ]),
        ]),
        const SizedBox(height:8),

        // Participants list
        if(_loadingPart) const Center(child:Padding(padding:EdgeInsets.all(20),child:CircularProgressIndicator(color:_pink)))
        else if(_participants.isEmpty) Container(padding:const EdgeInsets.all(20),
          decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),
          child:const Center(child:Text('Nenhum confirmado ainda.\nAdicione ou convide participantes!',textAlign:TextAlign.center,style:TextStyle(color:Colors.grey))))
        else Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16),
              boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:8)]),
            child:Column(children:_participants.asMap().entries.map((e)=>_partTile(e.key,e.value)).toList())),

        const SizedBox(height:20),
        Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),
          child:Column(children:[
            _infoRow(Icons.calendar_today_outlined,_fmtDate(_event.date)),
            const Divider(height:20),
            _infoRow(Icons.access_time_outlined,_event.time.substring(0,5)),
            const Divider(height:20),
            _infoRow(Icons.location_on_outlined,_event.location),
            if(_event.description!=null&&_event.description!.isNotEmpty)...[
              const Divider(height:20),
              _infoRow(Icons.label_outline,_event.description!),
            ],
            const Divider(height:20),
            _infoRow(Icons.people_outline,'${_event.maxParticipants} vagas  •  ${_event.availableSlots} disponíveis'),
          ])),
        const SizedBox(height:80),
      ]))),
    ]));
  }

  Widget _heroGrad() => Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xFFAA0055),_pink],begin:Alignment.topLeft,end:Alignment.bottomRight)),
      child:Center(child:Text(_emoji(_event.category),style:const TextStyle(fontSize:64))));

  Widget _toggle(String label,bool value) { final active=_toDentro==value; return Expanded(child:GestureDetector(onTap:()=>setState(()=>_toDentro=value),
    child:AnimatedContainer(duration:const Duration(milliseconds:200),padding:const EdgeInsets.symmetric(vertical:14),
      decoration:BoxDecoration(color:active?_pink:Colors.transparent,borderRadius:BorderRadius.circular(16)),
      child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        if(active)...[const Icon(Icons.check_circle,color:Colors.white,size:16),const SizedBox(width:6)],
        Text(label,style:TextStyle(color:active?Colors.white:Colors.grey,fontWeight:FontWeight.bold,fontSize:13)),
      ])))); }

  Widget _checklistTile(int index,ChecklistItem item) => ListTile(
    leading:GestureDetector(onTap:()=>setState(()=>_checklist[index].done=!item.done),
      child:AnimatedContainer(duration:const Duration(milliseconds:150),width:34,height:34,
        decoration:BoxDecoration(shape:BoxShape.circle,color:item.done?_pink.withOpacity(0.12):Colors.grey.shade100,border:Border.all(color:item.done?_pink:Colors.grey.shade300)),
        child:item.done?const Icon(Icons.check,color:_pink,size:16):null)),
    title:Text(item.task,style:TextStyle(fontWeight:FontWeight.w600,fontSize:14,decoration:item.done?TextDecoration.lineThrough:null,color:item.done?Colors.grey:Colors.black87)),
    subtitle:Text(item.assignedTo,style:const TextStyle(fontSize:12,color:Colors.grey)),
    trailing:IconButton(icon:const Icon(Icons.close,size:16,color:Colors.grey),onPressed:()=>setState(()=>_checklist.removeAt(index))));

  Widget _partTile(int index,Participant p) => ListTile(
    leading:CircleAvatar(backgroundColor:_pink.withOpacity(0.15),
        child:Text(p.name.isNotEmpty?p.name[0].toUpperCase():'?',style:const TextStyle(color:_pink,fontWeight:FontWeight.bold))),
    title:Text(p.name,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:14)),
    subtitle:Text(p.email,style:const TextStyle(color:Colors.grey,fontSize:12)),
    trailing:Row(mainAxisSize:MainAxisSize.min,children:[
      GestureDetector(onTap:()=>_togglePaid(p,index),
        child:Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:4),
          decoration:BoxDecoration(color:p.paid?Colors.green.shade50:Colors.orange.shade50,borderRadius:BorderRadius.circular(12),
              border:Border.all(color:p.paid?Colors.green.shade200:Colors.orange.shade200)),
          child:Text(p.paid?'Pago':'Pend.',style:TextStyle(color:p.paid?Colors.green.shade700:Colors.orange.shade700,fontSize:11,fontWeight:FontWeight.bold)))),
      const SizedBox(width:4),
      IconButton(icon:const Icon(Icons.remove_circle_outline,color:Colors.redAccent,size:20),onPressed:()=>_removeParticipant(p)),
    ]));

  Widget _infoRow(IconData icon,String text) => Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,size:16,color:Colors.grey),const SizedBox(width:10),
    Expanded(child:Text(text,style:const TextStyle(color:Colors.black87,fontSize:14))),
  ]);
}
