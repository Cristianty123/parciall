// lib/screens/entrepreneur/service_form_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class ServiceFormScreen extends StatefulWidget {
  final ServiceSummary? service;
  const ServiceFormScreen({super.key, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  List<Category> _categories = [];
  int? _selectedCategory;
  List<String> _imageUrls = [];
  bool _uploading = false;
  bool _saving = false;
  String? _error;

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (isEdit) {
      _titleCtrl.text = widget.service!.title;
      _descCtrl.text = widget.service!.description ?? '';
      _priceCtrl.text = widget.service!.price?.toStringAsFixed(0) ?? '';
      _imageUrls = List.from(widget.service!.imageUrls);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiClient.get('/categories');
      final list = json.decode(res.body) as List;
      setState(() {
        _categories = list.map((e) => Category.fromJson(e)).toList();
        if (isEdit && widget.service!.categoryName != null) {
          final match = _categories
              .where((c) => c.name == widget.service!.categoryName)
              .toList();
          if (match.isNotEmpty) _selectedCategory = match.first.id;
        }
      });
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return;
    setState(() => _uploading = true);
    try {
      final res = await ApiClient.uploadFile('/images/upload', File(xfile.path));
      if (res.statusCode == 201) {
        final url = json.decode(res.body)['url'] as String;
        setState(() => _imageUrls.add(url));
      } else {
        setState(() => _error = 'Error al subir imagen');
      }
    } catch (_) {
      setState(() => _error = 'Error al subir imagen');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _removeImage(String url) async {
    // Extract filename from URL
    final filename = url.split('/').last;
    try {
      await ApiClient.delete('/images/$filename');
    } catch (_) {}
    setState(() => _imageUrls.remove(url));
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El título es obligatorio');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final body = {
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()),
      'categoryId': _selectedCategory,
      'imageUrls': _imageUrls,
    };
    try {
      final res = isEdit
          ? await ApiClient.put('/services/${widget.service!.id}', body)
          : await ApiClient.post('/services', body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) Navigator.pop(context);
      } else {
        final msg = json.decode(res.body)['message'] as String?;
        setState(() => _error = msg ?? 'Error al guardar');
      }
    } catch (_) {
      setState(() => _error = 'Error de conexión');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? 'Editar servicio' : 'Nuevo servicio')),
      body: LoadingOverlay(
        loading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ErrorBanner(message: _error!),
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título *'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Descripción', alignLabelWithHint: true),
                maxLines: 4,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _priceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Precio (opcional)'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _selectedCategory,
                decoration:
                    const InputDecoration(labelText: 'Categoría (opcional)'),
                items: [
                  const DropdownMenuItem(
                      value: null, child: Text('Sin categoría')),
                  ..._categories.map((c) => DropdownMenuItem(
                      value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 20),
              const Text('Imágenes',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              // Image grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._imageUrls.map((url) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image))),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeImage(url),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )),
                  // Add button
                  GestureDetector(
                    onTap: _uploading ? null : _pickImage,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.5),
                            width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: AppTheme.primary.withOpacity(0.05),
                      ),
                      child: _uploading
                          ? const Center(
                              child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: AppTheme.primary),
                                Text('Agregar',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.primary)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(isEdit ? 'Guardar cambios' : 'Publicar servicio',
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
