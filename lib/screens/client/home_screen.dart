// lib/screens/client/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../shared/profile_screen.dart';
import '../shared/chat_list_screen.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LabApp'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Servicios'),
            Tab(icon: Icon(Icons.map_outlined), text: 'Mapa'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ChatListScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ServiceListTab(),
          _MapTab(),
        ],
      ),
    );
  }
}

// ── Lista de servicios ────────────────────────────────────────────────

class _ServiceListTab extends StatefulWidget {
  const _ServiceListTab();

  @override
  State<_ServiceListTab> createState() => _ServiceListTabState();
}

class _ServiceListTabState extends State<_ServiceListTab> {
  List<Category> _categories = [];
  List<ServiceCard> _services = [];
  bool _loading = true;
  int? _selectedCategory;
  final _searchCtrl = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadServices(reset: true);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        _hasMore &&
        !_loading) {
      _loadServices();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiClient.get('/categories');
      final list = json.decode(res.body) as List;
      setState(
          () => _categories = list.map((e) => Category.fromJson(e)).toList());
    } catch (_) {}
  }

  Future<void> _loadServices({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
    }
    setState(() => _loading = true);
    try {
      final params = <String, dynamic>{
        'page': _page,
        'size': '20',
      };
      if (_selectedCategory != null) {
        params['categoryId'] = _selectedCategory!;
      }
      final kw = _searchCtrl.text.trim();
      if (kw.isNotEmpty) params['keyword'] = kw;

      final res = await ApiClient.get('/services', params);
      final paged = PagedResponse.fromJson(
          json.decode(res.body), ServiceCard.fromJson);
      setState(() {
        if (reset) {
          _services = paged.content;
        } else {
          _services.addAll(paged.content);
        }
        _hasMore = _page < paged.totalPages - 1;
        _page++;
      });
    } catch (_) {
      setState(() {});
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar servicios...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _loadServices(reset: true);
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _loadServices(reset: true),
          ),
        ),
        // Category chips
        if (_categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() => _selectedCategory = null);
                        _loadServices(reset: true);
                      },
                    ),
                  );
                }
                final cat = _categories[i - 1];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.name),
                    selected: _selectedCategory == cat.id,
                    onSelected: (_) {
                      setState(() => _selectedCategory =
                          _selectedCategory == cat.id ? null : cat.id);
                      _loadServices(reset: true);
                    },
                  ),
                );
              },
            ),
          ),
        // Grid
        Expanded(
          child: _loading && _services.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _loadServices(reset: true),
                  child: GridView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: _services.length + (_hasMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _services.length) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final s = _services[i];
                      return ServiceCardWidget(
                        title: s.title,
                        imageUrl:
                            s.imageUrls.isNotEmpty ? s.imageUrls.first : null,
                        category: s.categoryName,
                        price: s.price,
                        rating: s.averageRating,
                        reviews: s.totalReviews,
                        entrepreneurName: s.entrepreneurFullName,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailScreen(serviceId: s.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Mapa ──────────────────────────────────────────────────────────────

class _MapTab extends StatefulWidget {
  const _MapTab();

  @override
  State<_MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<_MapTab> {
  List<ServiceMapMarker> _markers = [];
  bool _loading = true;
  final _mapCtrl = MapController();
  static const _center = LatLng(7.0669, -73.8539); // Floridablanca

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get('/services/map', {
        'lat': _center.latitude,
        'lng': _center.longitude,
        'radiusKm': 50,
      });
      final list = json.decode(res.body) as List;
      setState(() =>
          _markers = list.map((e) => ServiceMapMarker.fromJson(e)).toList());
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: const MapOptions(
            initialCenter: _center,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.labapp',
            ),
            MarkerLayer(
              markers: _markers
                  .map((m) => Marker(
                        point: LatLng(m.latitude, m.longitude),
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showMarkerInfo(m),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  m.title,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 9),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.location_on,
                                  color: AppTheme.primary, size: 24),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        if (_loading)
          const Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Cargando mapa...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showMarkerInfo(ServiceMapMarker m) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if (m.category != null) ...[
              const SizedBox(height: 6),
              Text(m.category!,
                  style: const TextStyle(color: AppTheme.primary)),
            ],
            if (m.entrepreneurFullName != null) ...[
              const SizedBox(height: 4),
              Text('Por ${m.entrepreneurFullName}',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(serviceId: m.id)),
                );
              },
              child: const Text('Ver detalle'),
            ),
          ],
        ),
      ),
    );
  }
}
