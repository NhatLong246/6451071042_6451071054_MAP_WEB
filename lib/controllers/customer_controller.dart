import 'package:flutter/material.dart';
import '../data/models/customer_model.dart';
import '../data/services/customer_service.dart';

class CustomerController extends ChangeNotifier {
  final CustomerService _service = CustomerService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filtered = [];
  Map<String, int> orderCountMap = {};
  bool isLoading = false;

  int currentPage = 1;
  int rowsPerPage = 10;

  List<CustomerModel> get paginatedData {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return _filtered.sublist(
      start,
      end > _filtered.length ? _filtered.length : end,
    );
  }

  int get totalPages => (_filtered.length / rowsPerPage).ceil().clamp(1, 9999);

  void changePage(int page) {
    currentPage = page;
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    isLoading = true;
    notifyListeners();
    _customers = await _service.getCustomers();
    _filtered = _customers;
    await _loadOrderCounts();
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadOrderCounts() async {
    for (final c in _customers) {
      orderCountMap[c.id] = await _service.getOrdersCount(c.id);
    }
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      _filtered = _customers;
    } else {
      final q = keyword.toLowerCase();
      _filtered = _customers.where((c) {
        return c.firstName.toLowerCase().contains(q) ||
            c.lastName.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q);
      }).toList();
    }
    currentPage = 1;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _service.deleteCustomer(id);
    await fetchCustomers();
  }

  Future<List<Map<String, dynamic>>> getOrders(String userId) {
    return _service.getOrdersOfUser(userId);
  }
}
