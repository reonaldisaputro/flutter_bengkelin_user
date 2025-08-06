import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/config/app_color.dart';
import 'package:flutter_bengkelin_user/model/cart_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/cart_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/checkout_page.dart';
import 'package:flutter_bengkelin_user/widget/custom_toast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class CartItem {
  final String image;
  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.image,
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartModel> _carts = [];

  @override
  void initState() {
    super.initState();
    getListCarts();
  }

  String _formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  int get _totalPrice {
    return _carts.fold(
      0,
          (sum, cart) => sum + (cart.price * cart.quantity),
    );
  }

  void _updateQuantity(int index, bool increment) {
    final cart = _carts[index];
    int currentQty = cart.quantity;
    int newQty = increment ? currentQty + 1 : (currentQty > 1 ? currentQty - 1 : currentQty);

    if (newQty == currentQty) return;

    setState(() {
      _carts[index].quantity = newQty;
    });

    updateQuantityCart(id: cart.id, qty: newQty);
  }



  void _removeItem(int index) {
    setState(() {
      _carts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: _carts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang kamu masih kosong',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yuk, belanja dulu!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ) : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _carts.length,
              separatorBuilder: (_, __) => const Divider(height: 30),
              itemBuilder: (context, index) {
                final cart = _carts[index];
                final product = cart.product;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${dotenv.env["IMAGE_BASE_URL"]}/${product.image}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 80,
                            width: 80,
                            color: AppColor.colorGrey,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatCurrency(product.price),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    // Quantity Control
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _updateQuantity(index, false),
                        ),
                        Text('${cart.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => _updateQuantity(index, true),
                        ),
                      ],
                    ),

                    // Remove Button
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        removeCart(id: cart.id);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Total Section
          _carts.isEmpty ? Container() : Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text(
                      'Total',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      _formatCurrency(_totalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carts.isEmpty
                        ? null
                        : () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(),),);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF355E4B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Lanjutkan Pembelian',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void getListCarts() async {
    await CartViewmodel().carts().then((value) {
      if (value.code == 200) {
        final listData = value.data as List;
        setState(() {
          _carts = listData.map((e) => CartModel.fromJson(e)).toList();
        });
      }
    });
  }

  removeCart({id}) async {
    await CartViewmodel().removeCart(id: id).then(
      (value) {
        if (value.code == 200){
          getListCarts();
        } else {
          if (!mounted) return;
          showToast(context: context, msg: value.message);
        }
      },
    );
  }

  updateQuantityCart({id, qty}) async {
    await CartViewmodel().updateQuantity(id: id, qty: qty).then(
          (value) {
        if (value.code == 200){
          getListCarts();
        } else {
          if (!mounted) return;
          showToast(context: context, msg: value.message);
        }
      },
    );
  }
}

