import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/service_item.dart';
import '../mock/mock_services.dart';

abstract class ServiceRepository {
  Future<List<ServiceItem>> getServices();
  Future<List<ServiceItem>> getServicesByProvider(String providerId);
  Future<void> addService(ServiceItem service);
  Future<void> updateService(ServiceItem service);
  Future<void> deleteService(String serviceId);
}

class MockServiceRepository implements ServiceRepository {
  final List<ServiceItem> _services = List.from(mockServices);

  @override
  Future<List<ServiceItem>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _services;
  }

  @override
  Future<List<ServiceItem>> getServicesByProvider(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _services.where((s) => s.providerId == providerId).toList();
  }

  @override
  Future<void> addService(ServiceItem service) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _services.add(service);
  }

  @override
  Future<void> updateService(ServiceItem service) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _services[index] = service;
    }
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _services.removeWhere((s) => s.id == serviceId);
  }
}

// Riverpod Provider
final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  return MockServiceRepository();
});

// Provider-specific Services Riverpod Provider
final providerServicesProvider = FutureProvider.family<List<ServiceItem>, String>((ref, providerId) async {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.getServicesByProvider(providerId);
});
