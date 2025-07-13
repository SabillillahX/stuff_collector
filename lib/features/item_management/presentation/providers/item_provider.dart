import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/item_model.dart';

class ItemState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  const ItemState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ItemNotifier extends StateNotifier<ItemState> {
  ItemNotifier() : super(const ItemState()) {
    _loadInitialData(); // This method loads the sample data
  }

  void _loadInitialData() {
    // These are the 3 sample items that appear on the dashboard
    final sampleItems = [
      Item(
        id: '1',
        name: 'Laptop',
        code: 'LTP001',
        category: 'Electronics',
        quantity: 5,
        price: 15000000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Item(
        id: '2',
        name: 'Office Chair',
        code: 'CHR001',
        category: 'Furniture',
        quantity: 10,
        price: 2500000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Item(
        id: '3',
        name: 'Notebook',
        code: 'NTB001',
        category: 'Stationery',
        quantity: 50,
        price: 25000.0,
        createdAt: DateTime.now(),
      ),
    ];

    state = state.copyWith(items: sampleItems);
  }

  void addItem(Item item) {
    final updatedItems = [...state.items, item];
    state = state.copyWith(items: updatedItems);
  }

  void updateItem(Item updatedItem) {
    final updatedItems = state.items
        .map((item) => item.id == updatedItem.id ? updatedItem : item)
        .toList();
    state = state.copyWith(items: updatedItems);
  }

  void deleteItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  List<Item> getItemsByCategory(String category) {
    return state.items.where((item) => item.category == category).toList();
  }

  Map<String, int> getCategoryStats() {
    final Map<String, int> stats = {};
    for (final item in state.items) {
      stats[item.category] = (stats[item.category] ?? 0) + item.quantity;
    }
    return stats;
  }
}

final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  return ItemNotifier();
});
