import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';


class EndUserScreen extends ConsumerWidget {
  const EndUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsyncValue = ref.watch(requestsProvider);
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: requestsAsyncValue.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('No requests submitted yet.'),
            );
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Request #${request.id}'),
                  subtitle: Text(request.items.map((e) => e.name).join(', ')),
                  trailing: _buildStatusChip(request.status),
                  onTap: () {
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateRequestDialog(context, ref, user!),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(RequestStatus status) {
    Color color;
    String text;

    switch (status) {
      case RequestStatus.Pending:
        color = Colors.blue;
        text = 'Pending';
        break;
      case RequestStatus.Confirmed:
        color = Colors.green;
        text = 'Confirmed';
        break;
      case RequestStatus.PartiallyFulfilled:
        color = Colors.orange;
        text = 'Partially Fulfilled';
        break;
    }

    return Chip(
      label: Text(text),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  void _showCreateRequestDialog(BuildContext context, WidgetRef ref, User user) {
    final selectedItems = <String>{};
    final allItems = ['Item A', 'Item B', 'Item C', 'Item D', 'Item E'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create New Request'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...allItems.map((item) {
                    return CheckboxListTile(
                      title: Text(item),
                      value: selectedItems.contains(item),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedItems.add(item);
                          } else {
                            selectedItems.remove(item);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedItems.isNotEmpty) {
                      ref.read(apiServiceProvider).createRequest(user.id, selectedItems.toList()).then((_) {
                        Navigator.of(context).pop();

                      }).catchError((e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create request: $e')),
                        );
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
