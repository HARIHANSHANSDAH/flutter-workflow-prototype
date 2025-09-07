import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';

import 'request_details_screen.dart';

class ReceiverScreen extends ConsumerWidget {
  const ReceiverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsyncValue = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Requests'),
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
          // Filter requests to show only those needing receiver action (Pending or Partially Fulfilled)
          final receiverRequests = requests.where((req) =>
          req.status == RequestStatus.Pending ||
              req.status == RequestStatus.PartiallyFulfilled).toList();

          if (receiverRequests.isEmpty) {
            return const Center(
              child: Text('No new requests.'),
            );
          }
          return ListView.builder(
            itemCount: receiverRequests.length,
            itemBuilder: (context, index) {
              final request = receiverRequests[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('Request #${request.id}'),
                  subtitle: Text('Status: ${_getStatusText(request.status)}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequestDetailsScreen(request: request),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.Pending:
        return 'Pending';
      case RequestStatus.PartiallyFulfilled:
        return 'Partially Fulfilled';
      case RequestStatus.Confirmed:
      return 'Unknown';
    }
  }
}
