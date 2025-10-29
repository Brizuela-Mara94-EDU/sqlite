import 'dart:io'; // Necesario para usar 'File'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite/models.dart';
import 'package:sqlite/shop_database.dart';

class ProductAdminScreen extends StatefulWidget {
  const ProductAdminScreen({super.key});

  @override
  State<ProductAdminScreen> createState() => _ProductAdminScreenState();
}

class _ProductAdminScreenState extends State<ProductAdminScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedImagePath;
  late Future<List<Product>> _productsFuture;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = ShopDatabase.instance.getAllProducts();
    });
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    setState(() {
      _selectedProduct = null;
      _selectedImagePath = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  void _onProductTap(Product product) {
    setState(() {
      _selectedProduct = product;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      _selectedImagePath = product.image;
    });
  }

  Future<void> _addProduct() async {
    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        price > 0 &&
        _selectedImagePath != null) {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        description: description,
        price: price,
        image: _selectedImagePath!,
      );
      await ShopDatabase.instance.insertProduct(newProduct);
      _refreshProducts();
      _clearForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos y selecciona una imagen.',
          ),
        ),
      );
    }
  }

  Future<void> _updateProduct() async {
    if (_selectedProduct == null) return;

    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = int.tryParse(_priceController.text) ?? 0;

    if (name.isNotEmpty &&
        description.isNotEmpty &&
        price > 0 &&
        _selectedImagePath != null) {
      final updatedProduct = _selectedProduct!.copyWith(
        name: name,
        description: description,
        price: price,
        image: _selectedImagePath!,
      );
      await ShopDatabase.instance.updateProduct(updatedProduct);
      _refreshProducts();
      _clearForm();
    }
  }

  Future<void> _deleteProduct() async {
    if (_selectedProduct == null) return;

    await ShopDatabase.instance.deleteProduct(_selectedProduct!.id);
    _refreshProducts();
    _clearForm();
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _pickImage,
        borderRadius: BorderRadius.circular(10),
        child: _selectedImagePath == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Seleccionar Imagen',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_selectedImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EEDC), // Fondo beige
      appBar: AppBar(
        title: const Text('Administrar Productos'),
        backgroundColor: const Color(0xFF6B4F4F), // Marrón consistente
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campos de texto con bordes suaves
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Título',
                prefixIcon: const Icon(Icons.shopping_cart),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Precio',
                prefixIcon: const Icon(Icons.price_change),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildImagePreview(),
            const SizedBox(height: 20),

            // Botones de acción con colores y estilo uniforme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Agregar'),
                ),
                ElevatedButton(
                  onPressed: _selectedProduct != null ? _updateProduct : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Actualizar'),
                ),
                ElevatedButton(
                  onPressed: _selectedProduct != null ? _deleteProduct : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
            const Divider(height: 40),

            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay productos.'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      Widget productImage;
                      if (product.image.startsWith('assets/')) {
                        productImage = Image.asset(
                          product.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        productImage = Image.file(
                          File(product.image),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      }
                      return Card(
                        elevation: 2,
                        color: _selectedProduct?.id == product.id
                            ? Colors.blue.shade100
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          onTap: () => _onProductTap(product),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: productImage,
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(product.description),
                          trailing: Text(
                            '\$${product.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
