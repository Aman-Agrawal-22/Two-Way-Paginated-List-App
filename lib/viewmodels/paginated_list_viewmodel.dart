import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import 'dart:async';

final paginatedListProvider =
    StateNotifierProvider<PaginatedListViewModel, PaginatedListState>((ref) {
  return PaginatedListViewModel();
});

class PaginatedListViewModel extends StateNotifier<PaginatedListState> {
  PaginatedListViewModel() : super(PaginatedListState());

  Future<void> fetchItems({required int id, required String direction}) async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await mockApiCall(id, direction);

      List<Item> newItems = response['data'];
      bool hasMore = response['hasMore'];

      if (direction == 'up') {
        newItems = newItems.reversed.toList();
        final existingIds = state.items.map((item) => item.id).toSet();
        newItems =
            newItems.where((item) => !existingIds.contains(item.id)).toList();

        state = state.copyWith(
          items: [...newItems, ...state.items],
          firstId: newItems.isNotEmpty ? newItems.first.id : state.firstId,
          hasMoreUp: hasMore,
        );
      } else {
        final existingIds = state.items.map((item) => item.id).toSet();
        newItems =
            newItems.where((item) => !existingIds.contains(item.id)).toList();

        state = state.copyWith(
          items: [...state.items, ...newItems],
          lastId: newItems.isNotEmpty ? newItems.last.id : state.lastId,
          hasMoreDown: hasMore,
        );
      }

    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch items.');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

class PaginatedListState {
  final List<Item> items;
  final List<Item> filteredItems;
  final int firstId;
  final int lastId;
  final bool hasMoreUp;
  final bool hasMoreDown;
  final bool isLoading;
  final String error;

  PaginatedListState({
    this.items = const [],
    this.filteredItems = const [],
    this.firstId = 0,
    this.lastId = 0,
    this.hasMoreUp = true,
    this.hasMoreDown = true,
    this.isLoading = false,
    this.error = '',
  });

  PaginatedListState copyWith({
    List<Item>? items,
    List<Item>? filteredItems,
    int? firstId,
    int? lastId,
    bool? hasMoreUp,
    bool? hasMoreDown,
    bool? isLoading,
    String? error,
  }) {
    return PaginatedListState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      firstId: firstId ?? this.firstId,
      lastId: lastId ?? this.lastId,
      hasMoreUp: hasMoreUp ?? this.hasMoreUp,
      hasMoreDown: hasMoreDown ?? this.hasMoreDown,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

Future<Map<String, dynamic>> mockApiCall(int id, String direction) async {
  await Future.delayed(Duration(seconds: 2)); // Simulated delay

  if (id < 0 || id > 2000) {
    return {'data': [], 'hasMore': false};
  }

  List<Item> items = List.generate(
    20,
    (index) {
      int newId = direction == 'up' ? id - (index + 1) : id + (index + 1);
      return Item(id: newId, title: 'Item $newId');
    },
  ).where((item) => item.id > 0 && item.id <= 2000).toList();

  bool hasMore = direction == 'up' ? id > 20 : id < 1980;

  return {'data': items, 'hasMore': hasMore};
}
