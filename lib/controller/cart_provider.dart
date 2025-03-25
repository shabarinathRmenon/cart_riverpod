import 'package:cart/controller/product_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class CartNotifier extends StateNotifier<List<Product>> {
  CartNotifier() : super([]);

  void addToCart(Product product) {
    final index = state.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      state = [
        for (final item in state)
          if (item.id == product.id)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ];
    } else {
      state = [...state, product.copyWith(quantity: 1)];
    }
  }

  void increaseQuantity(Product product) {
    state = state.map((item) =>
      item.id == product.id ? item.copyWith(quantity: item.quantity + 1) : item
    ).toList();
  }

 void decreaseQuantity(Product product) {
    state = state
        .map((item) =>
            item.id == product.id && item.quantity > 1
                ? item.copyWith(quantity: item.quantity - 1)
                : item)
        .where((item) => item.id != product.id || item.quantity > 1) 
        .toList();
  }

  void removeFromCart(Product product) {
    state = state.where((item) => item.id != product.id).toList();
  }
}



final cartProvider = StateNotifierProvider<CartNotifier, List<Product>>((ref) {
  return CartNotifier();
});
