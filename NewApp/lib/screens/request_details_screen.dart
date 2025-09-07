import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';


class RequestDetailsScreen extends ConsumerStatefulWidget {
  final Request request;
  const RequestDetailsScreen({super.key, required this.request});

  @override
  ConsumerState<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends ConsumerState<RequestDetailsScreen> {
  late List<Item> _items;

  @override
  void initState() {
    super.initState();
    // Initialize with existing item statuses
    _items = List.of(widget.request.items);
  }

  void _updateItemStatus(Item item, ItemStatus newStatus) {
    setState(() {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = Item(id: item.id, name: item.name, status: newStatus);
      }
    });
  }

  Future<void> _submitConfirmation() async {
    final apiService = ref.read(apiServiceProvider);
    final confirmations = _items.map((item) => {
      'id': item.id,
      'status': item.status.toString().split('.').last,
    }).toList();

    try {
      await apiService.updateRequest(widget.request.id, confirmations);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Confirmation submitted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit confirmation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request #${widget.request.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Review and confirm items:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusButton(item, ItemStatus.Available),
                          _buildStatusButton(item, ItemStatus.NotAvailable),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitConfirmation,
              child: const Text('Submit Confirmation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(Item item, ItemStatus status) {
    final isSelected = item.status == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(status.toString().split('.').last),
        selected: isSelected,
        onSelected: (selected) {
          _updateItemStatus(item, status);
        },
        selectedColor: status == ItemStatus.Available ? Colors.green : Colors.red,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
