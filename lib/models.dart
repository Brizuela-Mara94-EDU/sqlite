class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String image;

  Product(
      {required this.id,
      required this.name,
      required this.description,
      required this.price,
      required this.image});

  Product copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    String? image,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
    );
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      image: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image
    };
  }
}

class CartItem {
  final int id;
  final String name;
  final int price;
  final String image;
  int quantity;
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });
  get totalPrice {
    return quantity * price;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image
    };
  }
}
