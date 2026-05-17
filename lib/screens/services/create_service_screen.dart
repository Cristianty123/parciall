import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';

class CreateServiceScreen extends StatefulWidget {
  static const routeName = '/create-service';

  // Si se pasa un serviceId/data, se está editando
  final String? editServiceId;
  final Map<String, dynamic>? initialData;

  const CreateServiceScreen({super.key, this.editServiceId, this.initialData});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;
  String _category = 'Diseño';
  bool _active = true;

  bool get _isEditing => widget.editServiceId != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _titleCtrl = TextEditingController(text: d?['title'] ?? '');
    _priceCtrl = TextEditingController(text: d?['price'] ?? '');
    _locationCtrl = TextEditingController(text: d?['location'] ?? '');
    _descCtrl = TextEditingController(text: d?['description'] ?? '');
    _category = d?['category'] ?? 'Diseño';
    _active = d?['active'] ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final svcProv = context.read<ServicesProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    bool ok;
    if (_isEditing) {
      ok = await svcProv.updateService(widget.editServiceId!, {
        'title': _titleCtrl.text.trim(),
        'category': _category,
        'price': _priceCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'active': _active,
      });
    } else {
      ok = await svcProv.createService(
        provider: user,
        title: _titleCtrl.text.trim(),
        category: _category,
        description: _descCtrl.text.trim(),
        price: _priceCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
      );
    }

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Servicio actualizado exitosamente.'
              : 'Servicio publicado exitosamente.'),
          backgroundColor: const Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(svcProv.error ?? 'Ocurrió un error.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<ServicesProvider>().loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar servicio' : 'Publicar servicio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zona de imagen (placeholder visual)
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 54, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Toca para agregar imágenes',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Nombre del servicio *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoría *'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? 'Diseño'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Precio (ej: \$50.000)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'Ubicación *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'La ubicación es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción *'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'La descripción es obligatoria'
                    : null,
              ),
              const SizedBox(height: 20),

              // Toggle de estado activo/inactivo
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.toggle_on_outlined),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Servicio activo')),
                    Switch.adaptive(
                      value: _active,
                      onChanged: (v) => setState(() => _active = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _isEditing ? 'Guardar cambios' : 'Publicar servicio'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
