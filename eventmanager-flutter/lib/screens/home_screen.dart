import 'dart:io';                       
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import 'login_screen.dart';
import 'create_role_screen.dart';
import 'role_detail_screen.dart';
import 'invites_screen.dart';
import 'gastos_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _pink = Color(0xFFD4006A);
  int _navIndex = 0;
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'Todas';
  static const _categories = ['Todas','Conferência','Workshop','Show','Esporte','Social','Outro'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
      context.read<InviteProvider>().loadInvites();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async => await context.read<EventProvider>().loadEvents(
    query: _searchCtrl.text.trim(),
    category: _selectedCategory == 'Todas' ? null : _selectedCategory,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(index: _navIndex, children: [
        _buildRolesTab(),
        const CreateRoleScreen(),
        const GastosScreen(),
        const InvitesScreen(),
        const ProfileScreen(),
      ]),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildRolesTab() => SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _buildTopBar(),
    Padding(padding: const EdgeInsets.fromLTRB(20,20,20,0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Meus Rolês', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 12),
      TextField(controller: _searchCtrl, onChanged: (_) { setState((){}); _load(); },
        decoration: InputDecoration(
          hintText: '🔍  Buscar eventos...', prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: (){ _searchCtrl.clear(); _load(); setState((){}); }) : null,
        )),
      const SizedBox(height: 12),
      SizedBox(height: 36, child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: _categories.length,
        separatorBuilder: (_,__) => const SizedBox(width: 8),
        itemBuilder: (_,i) { final cat=_categories[i]; final active=cat==_selectedCategory;
          return GestureDetector(onTap: (){ setState(()=>_selectedCategory=cat); _load(); },
            child: AnimatedContainer(duration: const Duration(milliseconds:200),
              padding: const EdgeInsets.symmetric(horizontal:14,vertical:6),
              decoration: BoxDecoration(color: active?_pink:Colors.white, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active?_pink:Colors.grey.shade300)),
              child: Text(cat, style: TextStyle(color: active?Colors.white:Colors.black87, fontSize:12, fontWeight: active?FontWeight.bold:FontWeight.normal))));
        }),
      ),
    ])),
    Expanded(child: Consumer<EventProvider>(builder: (_,provider,__) {
      if (provider.loading) return const Center(child: CircularProgressIndicator(color: _pink));
      if (provider.events.isEmpty) return _buildEmpty();
      return RefreshIndicator(color: _pink, onRefresh: _load,
        child: ListView.separated(padding: const EdgeInsets.fromLTRB(20,12,20,100),
          itemCount: provider.events.length,
          separatorBuilder: (_,__) => const SizedBox(height:16),
          itemBuilder: (_,i) => _buildCard(provider.events[i])));
    })),
  ]));

  Widget _buildTopBar() => Container(color: Colors.white,
    padding: const EdgeInsets.fromLTRB(20,16,20,16),
    child: Row(children: [
      const Text('TôDentro!', style: TextStyle(color: _pink, fontSize:20, fontWeight:FontWeight.w900)),
      const Spacer(),
      GestureDetector(onTap: ()=>setState(()=>_navIndex=4),
        child: const CircleAvatar(radius:16, backgroundColor: Color(0xFFF3E8FF),
          child: Icon(Icons.person, color: _pink, size:18))),
    ]));

  Widget _buildEmpty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('🎉', style: TextStyle(fontSize:56)),
    const SizedBox(height:12),
    const Text('Nenhum rolê ainda!', style: TextStyle(fontSize:18, fontWeight:FontWeight.bold, color:Colors.black54)),
    const SizedBox(height:24),
    ElevatedButton.icon(onPressed: ()=>setState(()=>_navIndex=1),
      icon: const Icon(Icons.add), label: const Text('Criar Rolê'),
      style: ElevatedButton.styleFrom(backgroundColor:_pink, foregroundColor:Colors.white,
        padding: const EdgeInsets.symmetric(horizontal:24,vertical:12))),
  ]));

  Widget _buildCard(Event event) => GestureDetector(
    onTap: () async { await Navigator.push(context, MaterialPageRoute(builder:(_)=>RoleDetailScreen(event:event))); _load(); },
    child: Container(
      decoration: BoxDecoration(color:Colors.white, borderRadius:BorderRadius.circular(20),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.07), blurRadius:12, offset:const Offset(0,4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: (() {
                final hasCover = event.coverImageUrl != null && event.coverImageUrl!.isNotEmpty;
                if (!hasCover) return _buildEmojiBg(event);

                if (event.coverImageUrl!.startsWith('/')) {
                  return kIsWeb
                      ? Image.network(event.coverImageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildEmojiBg(event))
                      : Image.file(File(event.coverImageUrl!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildEmojiBg(event));
                }

                return Image.network(event.coverImageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildEmojiBg(event));
              })(),
            ),
          ),
          if (_isToday(event.date)) Positioned(top:12,right:12,child:Container(
            padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
            decoration: BoxDecoration(color:_pink, borderRadius:BorderRadius.circular(20)),
            child: const Text('É HOJE', style: TextStyle(color:Colors.white, fontSize:10, fontWeight:FontWeight.bold)))),
          Positioned(bottom:12,left:12,child:Container(
            padding: const EdgeInsets.symmetric(horizontal:10,vertical:5),
            decoration: BoxDecoration(color:Colors.black.withOpacity(0.55), borderRadius:BorderRadius.circular(20)),
            child: const Row(children:[Icon(Icons.circle,color:_pink,size:8),SizedBox(width:5),
              Text('TÔ DENTRO',style:TextStyle(color:Colors.white,fontSize:10,fontWeight:FontWeight.bold))]))),
        ]),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.name, style: const TextStyle(fontSize:18, fontWeight:FontWeight.w800)),
          const SizedBox(height:6),
          Row(children:[const Icon(Icons.location_on_outlined,size:14,color:Colors.grey),const SizedBox(width:4),
            Expanded(child:Text('${event.location}  •  ${event.time.substring(0,5)}', style: const TextStyle(color:Colors.grey,fontSize:13), overflow:TextOverflow.ellipsis))]),
          const SizedBox(height:10),
          Row(children:[
            ...List.generate(event.participantCount.clamp(0,3),(i)=>Transform.translate(offset:Offset(i*-10.0,0),
              child:Container(width:28,height:28,decoration:BoxDecoration(shape:BoxShape.circle,
                color:[Colors.pink.shade200,Colors.purple.shade200,Colors.blue.shade200][i%3],
                border:Border.all(color:Colors.white,width:2))))),
            const SizedBox(width:8),
            Text(event.participantCount==0?'Sem confirmados':'+${event.participantCount} CONFIRMADOS',
              style: const TextStyle(color:Colors.grey,fontSize:11,fontWeight:FontWeight.bold)),
          ]),
        ])),
      ])));

  Widget _buildBottomNav() => Consumer<InviteProvider>(builder:(_,inv,__)=>Container(
    decoration: BoxDecoration(color:Colors.white, boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.08),blurRadius:12,offset:const Offset(0,-2))]),
    child: SafeArea(child: SizedBox(height:60, child: Row(children:[
      _navItem(0,Icons.grid_view_rounded,'ROLÊS'),
      _navItem(1,Icons.add_circle_outline_rounded,'CRIAR'),
      _navItem(2,Icons.account_balance_wallet_outlined,'GASTOS'),
      _navBadge(3,Icons.mail_outline_rounded,'CONVITES',inv.pendingCount),
      _navItem(4,Icons.person_outline,'PERFIL'),
    ])))));

  Widget _navItem(int index,IconData icon,String label) => Expanded(child:GestureDetector(
    onTap:()=>setState(()=>_navIndex=index),
    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Icon(icon,color:_navIndex==index?_pink:Colors.grey,size:24),
      const SizedBox(height:3),
      Text(label,style:TextStyle(color:_navIndex==index?_pink:Colors.grey,fontSize:9,fontWeight:_navIndex==index?FontWeight.bold:FontWeight.normal)),
    ])));

  Widget _navBadge(int index,IconData icon,String label,int badge) => Expanded(child:GestureDetector(
    onTap:()=>setState(()=>_navIndex=index),
    child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Stack(clipBehavior:Clip.none,children:[
        Icon(icon,color:_navIndex==index?_pink:Colors.grey,size:24),
        if(badge>0) Positioned(top:-4,right:-6,child:Container(width:16,height:16,
          decoration:const BoxDecoration(color:_pink,shape:BoxShape.circle),
          child:Center(child:Text('$badge',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.bold))))),
      ]),
      const SizedBox(height:3),
      Text(label,style:TextStyle(color:_navIndex==index?_pink:Colors.grey,fontSize:9,fontWeight:_navIndex==index?FontWeight.bold:FontWeight.normal)),
    ])));

  bool _isToday(String date) { try { final d=DateTime.parse(date); final n=DateTime.now(); return d.year==n.year&&d.month==n.month&&d.day==n.day; } catch(_){return false;} }
  Color _catColor(String cat) => switch(cat){'Show'=>const Color(0xFF8B1A8B),'Conferência'=>const Color(0xFF1A4B8B),'Esporte'=>const Color(0xFF1A8B4B),'Workshop'=>const Color(0xFF8B5A1A),_=>const Color(0xFF8B1A4B)};
  String _emoji(String cat) => switch(cat){'Show'=>'🎵','Esporte'=>'⚽','Workshop'=>'🛠️','Conferência'=>'🎤',_=>'🎉'};

Widget _buildEmojiBg(Event event) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_catColor(event.category).withOpacity(0.8), _catColor(event.category)]), // <-- Parêntese corrigido aqui
      ),
      child: Center(child: Text(_emoji(event.category), style: const TextStyle(fontSize: 48))),
    );
  }
}


