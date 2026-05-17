import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ServicesProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();

  List<ServiceModel> _services = [];
  List<ServiceModel> _myServices = [];
  List<ServiceModel> _searchResults = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _loading = false;
  String? _error;

  List<ServiceModel> get services => _services;
  List<ServiceModel> get myServices => _myServices;
  List<ServiceModel> get searchResults => _searchResults;
  String? get selectedCategory => _selectedCategory;
  bool get loading => _loading;
  String? get error => _error;

  Stream<List<ServiceModel>> servicesStream({String? category}) =>
      _fs.servicesStream(category: category);

  Stream<List<ServiceModel>> myServicesStream(String providerId) =>
      _fs.myServicesStream(providerId);

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _searchResults = await _fs.searchServices(query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createService({
    required UserModel provider,
    required String title,
    required String category,
    required String description,
    required String price,
    required String location,
    List<String> imageUrls = const [],
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final service = ServiceModel(
        id: '',
        title: title,
        category: category,
        description: description,
        providerId: provider.uid,
        providerName: provider.name,
        providerPhotoUrl: provider.photoUrl,
        price: price,
        imageUrls: imageUrls,
        location: location,
        active: true,
        createdAt: DateTime.now(),
      );
      await _fs.createService(service);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear el servicio: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateService(
      String serviceId, Map<String, dynamic> data) async {
    try {
      await _fs.updateService(serviceId, data);
      return true;
    } catch (e) {
      _error = 'Error al actualizar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService(String serviceId) async {
    try {
      await _fs.deleteService(serviceId);
      return true;
    } catch (e) {
      _error = 'Error al eliminar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleServiceStatus(ServiceModel service) async {
    return updateService(service.id, {'active': !service.active});
  }
}
