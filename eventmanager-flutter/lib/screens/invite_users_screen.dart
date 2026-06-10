import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class InviteUsersScreen extends StatefulWidget {
  final Event event;
  const InviteUsersScreen({super.key, required this.event});

  @override
  State<InviteUsersScreen> createState() => _InviteUsersScreenState();
}

class _InviteUsersScreenState extends State<InviteUsersScreen>
    with SingleTickerProviderStateMixin {
  static const Color _pink = Color(0xFFD4006A);
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final ApiService  _api = ApiService();

  List<AppUser> _results = [];
  bool _searching  = false;
  bool _sendingEmail = false;
  String? _inviteLink;
  bool _generatingLink = false;
  final Set<int> _invitedIds = {};

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _generateLink();
  }

  @override
  void dispose() { _tabs.dispose(); _searchCtrl.dispose(); _emailCtrl.dispose(); super.dispose(); }

  Future<void> _generateLink() async {
    if (widget.event.id == null) return;
    setState(() => _generatingLink = true);
    try {
      final r = await _api.generateInviteLink(widget.event.id!);
      if (mounted) setState(() => _inviteLink = r['link']);
    } catch (_) {
      if (widget.event.inviteToken != null)
        setState(() => _inviteLink = 'todentro://invite/${widget.event.inviteToken}');
    } finally {
      if (mounted) setState(() => _generatingLink = false);
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) { setState(() => _results = []); return; }
    setState(() => _searching = true);
    try {
      final r = await _api.searchUsers(q.trim());
      if (mounted) setState(() => _results = r);
    } catch (_) { if (mounted) setState(() => _results = []); }
    finally { if (mounted) setState(() => _searching = false); }
  }

  Future<void> _inviteUser(AppUser user) async {
    if (widget.event.id == null) return;
    try {
      await _api.sendInviteByUserId(widget.event.id!, user.id);
      setState(() => _invitedIds.add(user.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Convite enviado para ${user.name}! ✉️'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: _pink));
    }
  }

  Future<void> _sendEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail inválido.'), backgroundColor: _pink));
      return;
    }
    if (widget.event.id == null) return;
    setState(() => _sendingEmail = true);
    try {
      await _api.sendInviteByEmail(widget.event.id!, email);
      _emailCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Convite enviado para $email! ✉️'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e'), backgroundColor: _pink));
    } finally { if (mounted) setState(() => _sendingEmail = false); }
  }

  void _shareLink() {
    if (_inviteLink == null) return;
    Share.share('🎉 Você foi convidado para "${widget.event.name}"!\n\n📅 ${widget.event.date}  •  🕐 ${widget.event.time}\n📍 ${widget.event.location}\n\nAceite: $_inviteLink', subject: 'Convite: ${widget.event.name}');
  }

  void _copyLink() {
    if (_inviteLink == null) return;
    Clipboard.setData(ClipboardData(text: _inviteLink!));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copiado! 📋'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: Text('"${widget.event.name}"', overflow: TextOverflow.ellipsis),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: Column(children: [
        Container(color: Colors.white, child: TabBar(
          controller: _tabs, labelColor: _pink, unselectedLabelColor: Colors.grey, indicatorColor: _pink,
          tabs: const [Tab(text: 'Buscar usuários'), Tab(text: 'Link de convite')])),
        Expanded(child: TabBarView(controller: _tabs, children: [_buildSearchTab(), _buildLinkTab()])),
      ]),
    );
  }

  Widget _buildSearchTab() => Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _searchCtrl, onChanged: _search,
        decoration: InputDecoration(hintText: 'Buscar por nome ou e-mail...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searching ? const Padding(padding: EdgeInsets.all(12),
              child: SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:_pink))) : null,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _pink, width: 1.5)))),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(hintText: 'Convidar por e-mail direto',
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _pink, width: 1.5))))),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: _sendingEmail ? null : _sendEmail,
          style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
          child: _sendingEmail ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
              : const Icon(Icons.send_outlined)),
      ]),
    ])),
    Expanded(child: _results.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('👥', style: TextStyle(fontSize: 48)), const SizedBox(height: 12),
            Text(_searchCtrl.text.length >= 2 ? 'Nenhum usuário encontrado.' : 'Digite para buscar usuários cadastrados',
                style: const TextStyle(color: Colors.grey))]))
        : ListView.separated(padding: const EdgeInsets.symmetric(horizontal:16),
            itemCount: _results.length, separatorBuilder: (_,__)=>const SizedBox(height:8),
            itemBuilder: (_,i)=>_userTile(_results[i]))),
  ]);

  Widget _userTile(AppUser user) {
    final invited = _invitedIds.contains(user.id);
    return Container(padding: const EdgeInsets.symmetric(horizontal:14,vertical:10),
      decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(14),
          boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.04),blurRadius:6)]),
      child: Row(children: [
        CircleAvatar(backgroundColor:_pink.withOpacity(0.15),
            child:Text(user.name.isNotEmpty?user.name[0].toUpperCase():'?',style:const TextStyle(color:_pink,fontWeight:FontWeight.bold))),
        const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(user.name,style:const TextStyle(fontWeight:FontWeight.w600,fontSize:14)),
          Text(user.email,style:const TextStyle(color:Colors.grey,fontSize:12)),
        ])),
        invited ? Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),
            decoration:BoxDecoration(color:Colors.green.shade50,borderRadius:BorderRadius.circular(20)),
            child:const Text('Convidado ✓',style:TextStyle(color:Colors.green,fontSize:12,fontWeight:FontWeight.bold)))
        : ElevatedButton(onPressed:()=>_inviteUser(user),
            style:ElevatedButton.styleFrom(backgroundColor:_pink,foregroundColor:Colors.white,
                shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),
                minimumSize:Size.zero,tapTargetSize:MaterialTapTargetSize.shrinkWrap),
            child:const Text('Convidar',style:TextStyle(fontSize:12))),
      ]));
  }

  Widget _buildLinkTab() => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding:const EdgeInsets.all(16), decoration:BoxDecoration(color:_pink,borderRadius:BorderRadius.circular(20)),
      child:Row(children:[
        Text(_emoji(widget.event.category),style:const TextStyle(fontSize:32)),const SizedBox(width:12),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(widget.event.name,style:const TextStyle(color:Colors.white,fontSize:16,fontWeight:FontWeight.w800)),
          Text('${widget.event.date}  •  ${widget.event.location}',style:const TextStyle(color:Colors.white70,fontSize:12)),
        ])),
      ])),
    const SizedBox(height:24),
    const Text('Link de convite',style:TextStyle(fontSize:16,fontWeight:FontWeight.bold)),
    const SizedBox(height:6),
    const Text('Qualquer pessoa com esse link pode entrar no rolê.',style:TextStyle(color:Colors.grey,fontSize:13)),
    const SizedBox(height:16),
    Container(padding:const EdgeInsets.all(14),
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.grey.shade200)),
      child:Row(children:[
        const Icon(Icons.link,color:_pink,size:20),const SizedBox(width:10),
        Expanded(child:_generatingLink?const Text('Gerando link...',style:TextStyle(color:Colors.grey))
            :Text(_inviteLink??'Erro ao gerar link',style:const TextStyle(fontSize:13),overflow:TextOverflow.ellipsis)),
        if(!_generatingLink&&_inviteLink!=null) GestureDetector(onTap:_copyLink,child:const Icon(Icons.copy_outlined,color:_pink,size:20)),
      ])),
    const SizedBox(height:16),
    SizedBox(width:double.infinity,child:ElevatedButton.icon(
      onPressed:_inviteLink!=null?_shareLink:null,
      icon:const Icon(Icons.share_outlined),
      label:const Text('Compartilhar link',style:TextStyle(fontWeight:FontWeight.bold,fontSize:15)),
      style:ElevatedButton.styleFrom(backgroundColor:_pink,foregroundColor:Colors.white,
          padding:const EdgeInsets.symmetric(vertical:14),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))))),
    const SizedBox(height:12),
    SizedBox(width:double.infinity,child:OutlinedButton.icon(
      onPressed:_inviteLink!=null?_copyLink:null,
      icon:const Icon(Icons.copy_outlined,color:_pink),
      label:const Text('Copiar link',style:TextStyle(color:_pink,fontWeight:FontWeight.bold)),
      style:OutlinedButton.styleFrom(side:const BorderSide(color:_pink),padding:const EdgeInsets.symmetric(vertical:14),
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(14))))),
    const SizedBox(height:24),
    Container(padding:const EdgeInsets.all(14),
      decoration:BoxDecoration(color:Colors.amber.shade50,borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.amber.shade200)),
      child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(Icons.info_outline,color:Colors.amber.shade700,size:18),const SizedBox(width:10),
        Expanded(child:Text('Quem clicar no link poderá confirmar presença sem precisar ter conta no TôDentro.',
            style:TextStyle(color:Colors.amber.shade800,fontSize:13))),
      ])),
  ]));

  String _emoji(String cat) => switch(cat){'Show'=>'🎵','Esporte'=>'⚽','Workshop'=>'🛠️','Conferência'=>'🎤',_=>'🎉'};
}
