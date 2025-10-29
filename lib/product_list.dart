import 'package:flutter/material.dart';
import 'package:sqlite/shop_database.dart';
import 'package:sqlite/models.dart';
import 'dart:io';

class ProductsList extends StatelessWidget {
  const ProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEDC), // 🎨 Fondo beige
      appBar: AppBar(
        title: const Text('Shop Sqlite'),
        backgroundColor: const Color(0xFF6B4F4F), // Marrón consistente
      ),
      body: FutureBuilder<List<Product>>(
        future: ShopDatabase.instance.getAllProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No hay productos disponibles.\nAgregue productos desde la pantalla de Administración.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          } else {
            final products = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: products.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () async {
                    await addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade700,
                        content: const Text("Producto agregado al carrito"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _ProductItem(product),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> addToCart(Product product) async {
    final item = CartItem(
      id: product.id,
      name: product.name,
      price: product.price,
      image: product.image,
      quantity: 1,
    );
    await ShopDatabase.instance.insert(item);
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;
  const _ProductItem(this.product);

  @override
  Widget build(BuildContext context) {
    Widget productImage;

    if (product.image.startsWith('assets/')) {
      productImage = Image.asset(
        product.image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      productImage = Image.file(
        File(product.image),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          );
        },
      );
    }

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: productImage,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.description,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                "\$${product.price}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
