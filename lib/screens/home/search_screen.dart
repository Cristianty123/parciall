import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/service_model.dart';
import '../../providers/services_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/service_card.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  final FirestoreService _fs = FirestoreService();
  String? _selectedCategory;
  List<ServiceModel>? _searchResults;
  bool _searching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = null;
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    final results = await _fs.searchServices(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar servicios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Busca por categoría o nombre del servicio',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: 'Todos',
                            selected: _selectedCategory == null,
                            onTap: () {
                              setState(() => _selectedCategory = null);
                              _onSearch(_searchCtrl.text);
                            },
                          ),
                        );
                      }
                      final cat = categories[index - 1];
                      return CategoryChip(
                        label: cat,
                        selected: _selectedCategory == cat,
                        onTap: () {
                          setState(() => _selectedCategory =
                              _selectedCategory == cat ? null : cat);
                          _searchCtrl.text = _selectedCategory ?? '';
                          _onSearch(_selectedCategory ?? '');
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults != null
                    ? _ResultsList(services: _searchResults!)
                    : _AllServicesStream(category: _selectedCategory),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}

class _AllServicesStream extends StatelessWidget {
  final String? category;

  const _AllServicesStream({this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ServiceModel>>(
      stream: FirestoreService().servicesStream(category: category),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final services = snap.data ?? [];
        if (services.isEmpty) {
          return const Center(
            child: Text('No se encontraron servicios.',
                style: TextStyle(color: Colors.grey)),
          );
        }
        return _ResultsList(services: services);
      },
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<ServiceModel> services;

  const _ResultsList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Sin resultados para tu búsqueda.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: services.length,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ServiceCard(service: services[index]),
      ),
    );
  }
}
