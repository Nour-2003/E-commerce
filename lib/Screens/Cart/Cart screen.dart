import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileproject/Cubit/Theme/Theme%20Cubit.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import 'Show Order Page.dart';


class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  Widget _buildCartItem(BuildContext context, DocumentSnapshot<Object?> item) {
    final data = item.data() as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                data['imageUrl'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${data['price'] ?? '0.00'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                final currentQuantity = data['quantity'] ?? 1;
                                if (currentQuantity > 1) {
                                  FirebaseFirestore.instance
                                      .collection('Cart')
                                      .doc(item.id)
                                      .update({'quantity': currentQuantity - 1});
                                  ShopCubit.get(context).getCartData();
                                }
                              },
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            Text(
                              '${data['quantity'] ?? 1}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                final currentQuantity = data['quantity'] ?? 1;
                                FirebaseFirestore.instance
                                    .collection('Cart')
                                    .doc(item.id)
                                    .update({'quantity': currentQuantity + 1});
                                ShopCubit.get(context).getCartData();
                              },
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('Cart')
                              .doc(item.id)
                              .delete();
                          ShopCubit.get(context).getCartData();
                        },
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTotal(List<DocumentSnapshot<Object?>> items) {
    return items.fold<double>(
      0,
          (sum, item) {
        final data = item.data() as Map<String, dynamic>? ?? {};
        final price = (double.parse(data['price']) ?? 0);
        final quantity = (data['quantity'] ?? 1).toInt();
        return sum + (price * quantity);
      },
    );
  }

  List<Map<String, dynamic>> _prepareOrderItems(List<DocumentSnapshot<Object?>> items) {
    return items.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'price': data['price'] ?? 0,
        'quantity': data['quantity'] ?? 1,
        'imageUrl': data['imageUrl'] ?? '',
      };
    }).toList();
  }

  Widget _buildCheckoutSection(BuildContext context, List<DocumentSnapshot<Object?>> items) {
    final total = _calculateTotal(items);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: ThemeCubit.get(context).themebool ? Colors.grey[800] : Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowOrderPage(
                    orderItems: _prepareOrderItems(items),
                    orderTotal: total,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {
        // Handle state changes if needed
      },
      builder: (context, state) {
        var cubit = ShopCubit.get(context);
        final items = cubit.CartItems.cast<DocumentSnapshot<Object?>>();

        if (state is GetCartData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          // appBar: AppBar(
          //   title: const Text('Shopping Cart'),
          //   elevation: 0,
          //   centerTitle: true,
          // ),
          body: items.isEmpty
              ? Center(
            child: Text(
              'Your cart is Empty',
              style: GoogleFonts.montserrat(fontSize: 18,),
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _buildCartItem(context, items[index]),
                ),
              ),
              _buildCheckoutSection(context, items),
            ],
          ),
        );
      },
    );
  }
}