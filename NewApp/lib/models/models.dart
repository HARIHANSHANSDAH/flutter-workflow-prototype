enum RequestStatus {
  Pending,
  Confirmed,
  PartiallyFulfilled,
}

enum ItemStatus {
  Pending,
  Available,
  NotAvailable,
}

enum UserRole {
  EndUser,
  Receiver,
}

class User {
  final int id;
  final String username;
  final UserRole role;

  User({required this.id, required this.username, required this.role});
}

class Item {
  final int id;
  final String name;
  final ItemStatus status;

  Item({required this.id, required this.name, this.status = ItemStatus.Pending});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      status: ItemStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
    );
  }
}

class Request {
  final int id;
  final int userId;
  final RequestStatus status;
  final List<Item> items;
  final DateTime timestamp;

  Request({
    required this.id,
    required this.userId,
    required this.status,
    required this.items,
    required this.timestamp,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      userId: json['userId'],
      status: RequestStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
