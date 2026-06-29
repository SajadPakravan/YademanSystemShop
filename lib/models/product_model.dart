class ProductModel {
  int? id;
  String? name;
  String? type;
  String? description;
  String? shortDescription;
  String? price;
  String? regularPrice;
  bool? onSale;
  int? quantity;
  int? totalSales;
  String? shippingClass;
  String? averageRating;
  int? ratingCount;
  List<ProductCategory>? categories;
  List<ProductBrand>? brands;
  List<ProductImage>? images;
  List<Attribute>? attributes;

  ProductModel({
    this.id,
    this.name,
    this.type,
    this.description,
    this.shortDescription,
    this.price,
    this.regularPrice,
    this.onSale,
    this.quantity,
    this.totalSales,
    this.shippingClass,
    this.averageRating,
    this.ratingCount,
    this.categories,
    this.brands,
    this.images,
    this.attributes,
  });

  ProductModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    description = json['description'];
    shortDescription = json['short_description'];
    price = json['price'];
    regularPrice = json['regular_price'];
    onSale = json['on_sale'];
    quantity = json['stock_quantity'];
    totalSales = json['total_sales'];
    shippingClass = json['shipping_class'];
    averageRating = json['average_rating'];
    ratingCount = json['rating_count'];
    if (json['categories'] != null) {
      categories = <ProductCategory>[];
      json['categories'].forEach((v) {
        categories!.add(ProductCategory.fromJson(v));
      });
    }
    if (json['brands'] != null) {
      brands = <ProductBrand>[];
      json['brands'].forEach((v) {
        brands!.add(ProductBrand.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = <ProductImage>[];
      json['images'].forEach((v) {
        images!.add(ProductImage.fromJson(v));
      });
    }
    if (json['attributes'] != null) {
      attributes = <Attribute>[];
      json['attributes'].forEach((v) {
        attributes!.add(Attribute.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['on_sale'] = onSale;
    data['on_sale'] = quantity;
    data['on_sale'] = totalSales;
    data['on_sale'] = shippingClass;
    data['on_sale'] = averageRating;
    data['on_sale'] = ratingCount;
    if (categories != null) data['categories'] = categories!.map((v) => v.toJson()).toList();
    if (brands != null) data['brands'] = brands!.map((v) => v.toJson()).toList();
    if (images != null) data['images'] = images!.map((v) => v.toJson()).toList();
    if (attributes != null) data['attributes'] = attributes!.map((v) => v.toJson()).toList();
    return data;
  }
}

class ProductCategory {
  int? id;
  String? name;

  ProductCategory({this.id, this.name});

  ProductCategory.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ProductBrand {
  int? id;
  String? name;

  ProductBrand({this.id, this.name});

  ProductBrand.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}

class ProductImage {
  int? id;
  String? src;

  ProductImage({this.id, this.src});

  ProductImage.fromJson(dynamic json) {
    id = json['id'];
    src = json['src'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['src'] = src;
    return data;
  }
}

class Attribute {
  String? name;
  List<String>? options;

  Attribute({this.name, this.options});

  Attribute.fromJson(dynamic json) {
    name = json['name'];
    options = json['options'] != null ? json['options'].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['options'] = options;
    return data;
  }
}
