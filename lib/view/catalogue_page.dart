import 'package:cart/controller/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/product_controller.dart';

class CataloguePage extends ConsumerStatefulWidget {
  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends ConsumerState<CataloguePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial products
    Future.microtask(() => ref.read(productProvider.notifier).fetchProducts());

    // Listen to Scroll Events for Pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(productProvider.notifier).fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink.shade100,
        title: Text('Catalogue', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cartState.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text('${cartState.length}',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
            ],
          )
        ],
      ),
      body: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: productState.length + 1, 
        itemBuilder: (context, index) {
          if (index == productState.length) {
            return Center(child: CircularProgressIndicator());
          }

          final product = productState[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(product.thumbnail, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.title, style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(children: [
                            Text(
                              '₹${(product.price * (1 - product.discount / 100)).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 1),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(width:1),
                            Text(
                              '${product.discount.toStringAsFixed(2)}% OFF',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 70,
                  right: 10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade200,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => ref.read(cartProvider.notifier).addToCart(product),
                    child: Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
