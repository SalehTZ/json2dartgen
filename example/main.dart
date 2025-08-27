import 'package:json2dartgen/json2dartgen.dart';

void main() {
  // Example 1: Simple JSON object to Dart class
  final simpleJson = {
    'id': 1,
    'name': 'John Doe',
    'is_active': true,
    'score': 95.5,
  };

  final generator = JsonToDartGenerator();
  final simpleClass = generator.generate(
    'User',
    simpleJson,
    useCamelCase: true,
  );
  print('// Example 1: Simple User class\n');
  print(simpleClass);

  // Example 2: Nested JSON objects
  final nestedJson = {
    'order_id': 'ORD12345',
    'customer': {'id': 101, 'name': 'Jane Smith', 'email': 'jane@example.com'},
    'items': [
      {
        'product_id': 'P1001',
        'name': 'Flutter Cookbook',
        'quantity': 2,
        'price': 39.99,
      },
      {
        'product_id': 'P1002',
        'name': 'Dart Programming',
        'quantity': 1,
        'price': 49.99,
      },
    ],
    'total': 129.97,
    'is_paid': false,
  };

  print('\n// Example 2: Nested JSON with arrays\n');
  final orderClass = generator.generate(
    'Order',
    nestedJson,
    useCamelCase: true,
  );
  print(orderClass);

  // Example 3: Generate multiple models at once
  final multiModelJson = {
    'user': {
      'id': 1,
      'username': 'dev_user',
      'profile': {
        'full_name': 'Alex Johnson',
        'avatar_url': 'https://example.com/avatars/alex.jpg',
      },
    },
    'settings': {'theme': 'dark', 'notifications': true, 'language': 'en'},
  };

  print('\n// Example 3: Generate multiple models\n');
  final models = generator.generate(
    'MultiModel',
    multiModelJson,
    useCamelCase: true,
  );
  print(models);

  // Example 4: Using the generated code (simulated)
  print('\n// Example 4: Using the generated models\n');
  print('''
// This is how you would use the generated classes in your code:

// First, run the build_runner to generate the .g.dart files:
// flutter pub run build_runner build

// Then import the generated files:
// import 'order.g.dart';
// import 'user.g.dart';

// Create a new order:
final order = Order(
  orderId: 'ORD12345',
  customer: Customer(
    id: 101,
    name: 'Jane Smith',
    email: 'jane@example.com',
  ),
  items: [
    OrderItem(
      productId: 'P1001',
      name: 'Flutter Cookbook',
      quantity: 2,
      price: 39.99,
    ),
    OrderItem(
      productId: 'P1002',
      name: 'Dart Programming',
      quantity: 1,
      price: 49.99,
    ),
  ],
  total: 129.97,
  isPaid: false,
);

// Convert to JSON:
final orderJson = order.toJson();
print(jsonEncode(orderJson));

// Parse from JSON:
final parsedOrder = Order.fromJson(jsonDecode(\'''
  {
    "order_id": "ORD12345",
    "customer": {
      "id": 101,
      "name": "Jane Smith",
      "email": "jane@example.com"
    },
    "items": [
      {
        "product_id": "P1001",
        "name": "Flutter Cookbook",
        "quantity": 2,
        "price": 39.99
      }
    ],
    "total": 39.99,
    "is_paid": true
  }
\'''));

// Use copyWith to create a modified copy:
final updatedOrder = order.copyWith(
  isPaid: true,
  items: [...order.items, 
    OrderItem(
      productId: 'P1003',
      name: 'Advanced Flutter',
      quantity: 1,
      price: 59.99,
    ),
  ],
);
''');
}
