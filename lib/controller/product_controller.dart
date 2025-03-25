import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Product {
  final int id;
  final String title;
  final String thumbnail;
  final double price;
  final double discount;
  final String brand;
  final int quantity;

  Product({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.discount,
    required this.brand,
    this.quantity = 1, 
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      price: json['price'].toDouble(),
      discount: json['discountPercentage'].toDouble(),
      brand: json['brand'] ?? 'Unknown Brand', 
    );
  }

  
  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      title: title,
      thumbnail: thumbnail,
      price: price,
      discount: discount,
      brand: brand,
      quantity: quantity ?? this.quantity,
    );
  }
}



class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]);
  
  int _page = 1;
  bool _isFetching = false;

  Future<void> fetchProducts() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final response = await Dio().get('https://dummyjson.com/products', queryParameters: {
        'limit': 10,  
        'skip': (_page - 1) * 10,
      });

      final List products = response.data['products'];
      if (products.isNotEmpty) {
        state = [...state, ...products.map((json) => Product.fromJson(json))];
        _page++;
      }
    } catch (e) {
      print("Error fetching products: $e");
    }

    _isFetching = false;
  }
}


final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((ref) {
  return ProductNotifier();
});
