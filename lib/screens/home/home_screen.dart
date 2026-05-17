import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/section_title.dart';
import '../../widgets/service_card.dart';
import '../home/search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _fs = FirestoreService();
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, ${user?.name.split(' ').first ?? 'Usuario'}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Encuentra servicios cerca de ti',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: user?.photoUrl != null
                              ? NetworkImage(user!.photoUrl!)
                              : const NetworkImage(
                                  'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Barra de búsqueda (navega a SearchScreen)
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, SearchScreen.routeName),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText:
                                'Buscar diseño, tutorías, reparaciones...',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const SectionTitle(title: 'Categorías'),
                    const SizedBox(height: 16),

                    // Chips de categorías
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
                                onTap: () =>
                                    setState(() => _selectedCategory = null),
                              ),
                            );
                          }
                          final cat = categories[index - 1];
                          return CategoryChip(
                            label: cat,
                            selected: _selectedCategory == cat,
                            onTap: () => setState(
                                () => _selectedCategory =
                                    _selectedCategory == cat ? null : cat),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle(title: 'Servicios destacados'),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Lista de servicios desde Firestore
            StreamBuilder<List<ServiceModel>>(
              stream: _fs.servicesStream(category: _selectedCategory),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    )),
                  );
                }

                final services = snap.data ?? [];

                if (services.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              _selectedCategory != null
                                  ? 'No hay servicios en "$_selectedCategory"'
                                  : 'Aún no hay servicios publicados.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServiceCard(service: services[index]),
                      ),
                      childCount: services.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
