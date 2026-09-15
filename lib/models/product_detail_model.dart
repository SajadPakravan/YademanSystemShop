import 'package:yad_sys/models/product_card_model.dart';
import 'package:yad_sys/models/review_card_model.dart';
import 'package:yad_sys/models/section_item_action_model.dart';

class ProductDetailModel {
  const ProductDetailModel({required this.success, required this.data});

  final bool success;
  final ProductDetail data;

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(success: json['success'], data: ProductDetail.fromJson(json['data']));
  }
}

class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.regularPrice,
    required this.discountPercent,
    required this.stockQuantity,
    required this.image,
    required this.variationName,
    required this.averageRating,
    required this.ratingCount,
    required this.reviewCount,
    required this.totalSales,
    required this.categories,
    required this.brand,
    required this.tags,
    required this.gallery,
    required this.dimensions,
    required this.shippingClass,
    required this.attributes,
    required this.defaultVariation,
    required this.variations,
    required this.reviews,
    required this.relatedProducts,
  });

  final int id;
  final String sku;
  final String name;
  final String description;
  final int price;
  final int regularPrice;
  final int discountPercent;
  final int stockQuantity;
  final String image;
  final String variationName;
  final String averageRating;
  final int ratingCount;
  final int reviewCount;
  final int totalSales;
  final List<ProductDetailCategory> categories;
  final ProductDetailBrand brand;
  final List<dynamic> tags;
  final List<String> gallery;
  final ProductDimensions dimensions;
  final String shippingClass;
  final List<ProductAttribute> attributes;
  final int? defaultVariation;
  final List<ProductVariation> variations;
  final List<ProductDetailReview> reviews;
  final List<RelatedProduct> relatedProducts;

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'],
      sku: json['sku'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      regularPrice: json['regular_price'],
      discountPercent: json['discount_percent'],
      stockQuantity: json['stock_quantity'],
      image: json['image'],
      variationName: json['variation_name'],
      averageRating: json['average_rating'],
      ratingCount: json['rating_count'],
      reviewCount: json['review_count'],
      totalSales: json['total_sales'],
      categories: List.castFrom(json['categories']).map((item) => ProductDetailCategory.fromJson(item)).toList(growable: false),
      brand: ProductDetailBrand.fromJson(json['brand']),
      tags: List<dynamic>.from(json['tags']),
      gallery: List<String>.from(json['gallery']),
      dimensions: ProductDimensions.fromJson(json['dimensions']),
      shippingClass: json['shipping_class'],
      attributes: List.castFrom(json['attributes']).map((item) => ProductAttribute.fromJson(item)).toList(growable: false),
      defaultVariation: json['default_variation'],
      variations: List.castFrom(json['variations']).map((item) => ProductVariation.fromJson(item)).toList(growable: false),
      reviews: List.castFrom(json['reviews']).map((item) => ProductDetailReview.fromJson(item)).toList(growable: false),
      relatedProducts: List.castFrom(json['related_products']).map((item) => RelatedProduct.fromJson(item)).toList(growable: false),
    );
  }
}

class ProductDetailCategory {
  const ProductDetailCategory({required this.id, required this.name, required this.image});

  final int id;
  final String name;
  final String image;

  factory ProductDetailCategory.fromJson(Map<String, dynamic> json) {
    return ProductDetailCategory(id: json['id'], name: json['name'], image: json['image']);
  }
}

class ProductDetailBrand {
  const ProductDetailBrand({required this.id, required this.name, required this.image});

  final int id;
  final String name;
  final String image;

  factory ProductDetailBrand.fromJson(Map<String, dynamic> json) {
    return ProductDetailBrand(id: json['id'], name: json['name'], image: json['image']);
  }
}

class ProductDimensions {
  const ProductDimensions({required this.length, required this.width, required this.height});

  final String? length;
  final String? width;
  final String? height;

  factory ProductDimensions.fromJson(Map<String, dynamic> json) {
    return ProductDimensions(length: json['length']?.toString(), width: json['width']?.toString(), height: json['height']?.toString());
  }
}

class ProductAttribute {
  const ProductAttribute({required this.name, required this.visible, required this.options});

  final String name;
  final bool visible;
  final List<String> options;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(name: json['name'], visible: json['visible'], options: List<String>.from(json['options']));
  }
}

class ProductVariation {
  const ProductVariation({required this.id, required this.name, required this.options});

  final int id;
  final String name;
  final List<ProductVariationOption> options;

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'],
      name: json['name'],
      options: List.castFrom(json['options']).map((item) => ProductVariationOption.fromJson(item)).toList(growable: false),
    );
  }
}

class ProductVariationOption {
  const ProductVariationOption({
    required this.id,
    required this.name,
    required this.sku,
    required this.color,
    required this.image,
    required this.price,
    required this.regularPrice,
    required this.discountPercent,
    required this.stockQuantity,
    required this.productImage,
  });

  final int id;
  final String name;
  final String sku;
  final String color;
  final String image;
  final int price;
  final int regularPrice;
  final int discountPercent;
  final int stockQuantity;
  final String productImage;

  factory ProductVariationOption.fromJson(Map<String, dynamic> json) {
    return ProductVariationOption(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      color: json['color'],
      image: json['image'],
      price: json['price'],
      regularPrice: json['regular_price'],
      discountPercent: json['discount_percent'],
      stockQuantity: json['stock_quantity'],
      productImage: json['product_image'],
    );
  }
}

class ProductDetailReview {
  const ProductDetailReview({required this.data, required this.viewAll});

  final List<ReviewCardModel> data;
  final ProductDetailViewAll? viewAll;

  factory ProductDetailReview.fromJson(Map<String, dynamic> json) {
    return ProductDetailReview(
      data: List.castFrom(json['data']).map((item) => ReviewCardModel.fromJson(item)).toList(growable: false),
      viewAll: json['view_all'] is Map ? ProductDetailViewAll.fromJson(Map<String, dynamic>.from(json['view_all'])) : null,
    );
  }
}

class RelatedProduct {
  const RelatedProduct({required this.data, required this.viewAll});

  final List<ProductCardModel> data;
  final ProductDetailViewAll? viewAll;

  factory RelatedProduct.fromJson(Map<String, dynamic> json) {
    return RelatedProduct(
      data: List.castFrom(json['data']).map((item) => ProductCardModel.fromJson(Map<String, dynamic>.from(item))).toList(growable: false),
      viewAll: json['view_all'] is Map ? ProductDetailViewAll.fromJson(Map<String, dynamic>.from(json['view_all'])) : null,
    );
  }
}

class ProductDetailViewAll {
  const ProductDetailViewAll({required this.title, required this.action});

  final String title;
  final SectionItemActionModel action;

  factory ProductDetailViewAll.fromJson(Map<String, dynamic> json) {
    return ProductDetailViewAll(title: json['title'], action: SectionItemActionModel.fromJson(json['action']));
  }
}

class ProductDetailViewAllAction {
  const ProductDetailViewAllAction({
    required this.title,
    required this.type,
    required this.destinationId,
    required this.onSale,
    required this.url,
    required this.orderby,
    required this.order,
  });

  final String title;
  final String type;
  final int? destinationId;
  final bool? onSale;
  final String? url;
  final String orderby;
  final String order;

  factory ProductDetailViewAllAction.fromJson(Map<String, dynamic> json) {
    return ProductDetailViewAllAction(
      title: json['title'],
      type: json['type'],
      destinationId: json['destination_id'],
      onSale: json['on_sale'],
      url: json['url'],
      orderby: json['orderby'],
      order: json['order'],
    );
  }
}
