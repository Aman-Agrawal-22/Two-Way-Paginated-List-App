import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/paginated_list_viewmodel.dart';
import '../widgets/shimmer_effect.dart';

class PaginatedListScreen extends ConsumerWidget {
  const PaginatedListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginatedListProvider);
    final viewModel = ref.read(paginatedListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated List'),
        centerTitle: true,
        backgroundColor: Colors.teal, 
        elevation: 4, 
      ),
      body: state.error.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.error,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.minScrollExtent &&
                    state.hasMoreUp &&
                    !state.isLoading) {
                  viewModel.fetchItems(id: state.firstId, direction: 'up');
                } else if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    state.hasMoreDown &&
                    !state.isLoading) {
                  viewModel.fetchItems(id: state.lastId, direction: 'down');
                }
                return false;
              },
              child: state.isLoading && state.items.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) 
                  : ListView.builder(
                      itemCount: state.items.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return ShimmerEffect(); 
                        }

                        final item = state.items[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4, // Shadow effect for each item
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}


