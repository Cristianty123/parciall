// lib/screens/shared/edit_profile_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nameCtrl =
      TextEditingController(text: widget.profile.fullName ?? '');
  late final _descCtrl =
      TextEditingController(text: widget.profile.description ?? '');
  late final _addressCtrl =
      TextEditingController(text: widget.profile.address ?? '');
  String? _photoUrl;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.profile.photoUrl;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final res =
          await ApiClient.uploadFile('/images/upload', File(xfile.path));
      if (res.statusCode == 201) {
        final url = json.decode(res.body)['url'] as String;
        setState(() => _photoUrl = url);
      } else {
        setState(() => _error = 'Error al subir foto');
      }
    } catch (_) {
      setState(() => _error = 'Error al subir foto');
    } finally {
      setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'El nombre no puede estar vacío');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final res = await ApiClient.put('/users/me', {
        'fullName': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'photoUrl': _photoUrl,
      });
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado')),
          );
          Navigator.pop(context);
        }
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
      appBar: AppBar(title: const Text('Editar perfil')),
      body: LoadingOverlay(
        loading: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Photo
              Center(
                child: Stack(
                  children: [
                    UserAvatar(photoUrl: _photoUrl, radius: 50),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _uploadingPhoto ? null : _pickPhoto,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _uploadingPhoto
                              ? const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_error != null) ErrorBanner(message: _error!),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre completo *'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dirección / Ubicación',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: const Text('Guardar cambios',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
