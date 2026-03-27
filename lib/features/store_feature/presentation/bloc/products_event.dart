import 'dart:async';

import 'package:recycleorigin/features/store_feature/business/entities/color_code_card.dart';
import 'package:recycleorigin/features/store_feature/business/entities/color_code_product_detail.dart';
import 'package:recycleorigin/features/store_feature/business/entities/order_send_details.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product.dart';
import 'package:recycleorigin/features/store_feature/business/entities/product_cart.dart';

/// Events for [ProductsBloc].
sealed class ProductsEvent {
  const ProductsEvent();
}

class ProductsCartItemsSet extends ProductsEvent {
  const ProductsCartItemsSet(this.cartItems);
  final List<ProductCart> cartItems;
}

class ProductsItemSet extends ProductsEvent {
  const ProductsItemSet(this.item);
  final Product item;
}

class ProductsSearchParamsChanged extends ProductsEvent {
  const ProductsSearchParamsChanged({
    this.searchKey,
    this.sPage,
    this.sPerPage,
    this.sOrder,
    this.sOrderBy,
    this.sCategory,
    this.clearSCategory = false,
  });
  final String? searchKey;
  final int? sPage;
  final int? sPerPage;
  final String? sOrder;
  final String? sOrderBy;
  final Object? sCategory;
  final bool clearSCategory;
}

class ProductsSearchBuilderApplied extends ProductsEvent {
  const ProductsSearchBuilderApplied();
}

class ProductsCheckFilteredRequested extends ProductsEvent {
  const ProductsCheckFilteredRequested();
}

class ProductsAddShopCartRequested extends ProductsEvent {
  const ProductsAddShopCartRequested(
    this.product,
    this.colorId,
    this.quantity, {
    this.completer,
  });
  final Product product;
  final ColorCodeProductDetail colorId;
  final int quantity;
  final Completer<void>? completer;
}

class ProductsUpdateShopCartRequested extends ProductsEvent {
  const ProductsUpdateShopCartRequested(
    this.product,
    this.colorId,
    this.quantity,
    this.isLogin, {
    this.completer,
  });
  final ProductCart product;
  final ColorCodeCard colorId;
  final int quantity;
  final bool isLogin;
  final Completer<void>? completer;
}

class ProductsRemoveShopCartRequested extends ProductsEvent {
  const ProductsRemoveShopCartRequested(this.productId, {this.completer});
  final int productId;
  final Completer<void>? completer;
}

class ProductsRetrieveCategoryRequested extends ProductsEvent {
  const ProductsRetrieveCategoryRequested({this.completer});
  final Completer<void>? completer;
}

class ProductsSearchItemRequested extends ProductsEvent {
  const ProductsSearchItemRequested({this.completer});
  final Completer<void>? completer;
}

class ProductsRetrieveItemRequested extends ProductsEvent {
  const ProductsRetrieveItemRequested(this.productId, {this.completer});
  final int productId;
  final Completer<void>? completer;
}

class ProductsSendRequestRequested extends ProductsEvent {
  const ProductsSendRequestRequested(this.request, {this.completer});
  final OrderSendDetails request;
  final Completer<void>? completer;
}
