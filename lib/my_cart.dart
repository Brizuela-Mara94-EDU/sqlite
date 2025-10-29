import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqlite/models.dart';
import 'package:sqlite/notifier.dart';
import 'package:sqlite/shop_database.dart';

class MyCart extends StatelessWidget {
  const MyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEDC), // 🎨 Fondo beige
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        backgroundColor: const Color(0xFF6B4F4F), // Marrón consistente
      ),
      body: Consumer<CartNotifier>(
        builder: (context, cart, child) {
          return FutureBuilder<List<CartItem>>(
            future: ShopDatabase.instance.getAllItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay productos en tu carrito",
                    style: TextStyle(fontSize: 20),
                  ),
                );
              } else {
                final cartItems = snapshot.data!;
                final double total = cartItems.fold(
                    0, (sum, item) => sum + item.totalPrice);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return _CartItem(cartItems[index]);
                        },
                      ),
                    ),
                    // 🧾 Total del carrito
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6B4F4F),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartItem cartItem;
  const _CartItem(this.cartItem);

  @override
  Widget build(BuildContext context) {
    Widget productImage;

    if (cartItem.image.startsWith('assets/')) {
      productImage = Image.asset(
        cartItem.image,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else {
      productImage = Image.file(
        File(cartItem.image),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade200,
            child:
                const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          );
        },
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: productImage,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text("\$${cartItem.price} c/u",
                      style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(
                    "Total: \$${cartItem.totalPrice}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            // --- Controles de cantidad y eliminar ---
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _updateQuantity(context, -1),
                    ),
                    Text(
                      cartItem.quantity.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () => _updateQuantity(context, 1),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _deleteItem(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(BuildContext context, int change) {
    final notifier = Provider.of<CartNotifier>(context, listen: false);
    cartItem.quantity += change;

    if (cartItem.quantity <= 0) {
      ShopDatabase.instance.delete(cartItem.id);
    } else {
      ShopDatabase.instance.update(cartItem);
    }
    notifier.shouldRefresh();
  }

  void _deleteItem(BuildContext context) {
    final notifier = Provider.of<CartNotifier>(context, listen: false);
    ShopDatabase.instance.delete(cartItem.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Producto eliminado del carrito"),
        duration: Duration(seconds: 2),
      ),
    );
    notifier.shouldRefresh();
  }
}
