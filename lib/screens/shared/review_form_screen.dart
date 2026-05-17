// lib/screens/shared/review_form_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../widgets/widgets.dart';

class ReviewFormScreen extends StatefulWidget {
  final int entrepreneurId;
  final int servicePostId;
  final String serviceTitle;

  const ReviewFormScreen({
    super.key,
    required this.entrepreneurId,
    required this.servicePostId,
    required this.serviceTitle,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Selecciona al menos 1 estrella');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final res = await ApiClient.post('/reviews', {
        'entrepreneurId': widget.entrepreneurId,
        'servicePostId': widget.servicePostId,
        'rating': _rating,
        'comment': _commentCtrl.text.trim(),
      });
      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Reseña enviada!')),
          );
          Navigator.pop(context);
        }
      } else if (res.statusCode == 409) {
        setState(() => _error = 'Ya escribiste una reseña para este servicio');
      } else if (res.statusCode == 403) {
        setState(() => _error = 'Solo los clientes pueden escribir reseñas');
      } else {
        final msg = json.decode(res.body)['message'] as String?;
        setState(() => _error = msg ?? 'Error al enviar reseña');
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
      appBar: AppBar(title: const Text('Escribir reseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Califica: ${widget.serviceTitle}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            if (_error != null) ErrorBanner(message: _error!),
            const Text('Tu calificación',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Center(
              child: StarSelector(
                selected: _rating,
                onSelect: (v) => setState(() => _rating = v),
                size: 44,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _rating == 0
                    ? 'Toca las estrellas para calificar'
                    : _ratingLabel(_rating),
                style: TextStyle(
                  color: _rating == 0
                      ? Colors.grey
                      : const Color(0xFF5C6BC0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Comentario (opcional)',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              decoration: const InputDecoration(
                hintText: 'Cuéntanos tu experiencia...',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: (_saving || _rating == 0) ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Enviar reseña',
                      style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Bueno';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }
}
