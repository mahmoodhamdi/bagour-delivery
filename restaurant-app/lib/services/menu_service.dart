import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../config/constants.dart';

/// Menu service provider
final menuServiceProvider = Provider<MenuService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MenuService(apiService);
});

/// Menu item addon model
class MenuAddon {
  final String? id;
  final String name;
  final String nameAr;
  final double price;
  final bool isAvailable;
  final int maxQuantity;

  MenuAddon({
    this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    this.isAvailable = true,
    this.maxQuantity = 5,
  });

  factory MenuAddon.fromJson(Map<String, dynamic> json) {
    return MenuAddon(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      maxQuantity: json['maxQuantity'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'nameAr': nameAr,
      'price': price,
      'isAvailable': isAvailable,
      'maxQuantity': maxQuantity,
    };
  }

  MenuAddon copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? price,
    bool? isAvailable,
    int? maxQuantity,
  }) {
    return MenuAddon(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }
}

/// Variation option model
class VariationOption {
  final String? id;
  final String name;
  final String nameAr;
  final double price;

  VariationOption({
    this.id,
    required this.name,
    required this.nameAr,
    required this.price,
  });

  factory VariationOption.fromJson(Map<String, dynamic> json) {
    return VariationOption(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'nameAr': nameAr,
      'price': price,
    };
  }

  VariationOption copyWith({
    String? id,
    String? name,
    String? nameAr,
    double? price,
  }) {
    return VariationOption(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      price: price ?? this.price,
    );
  }
}

/// Menu item variation model
class MenuVariation {
  final String? id;
  final String name;
  final String nameAr;
  final bool isRequired;
  final List<VariationOption> options;

  MenuVariation({
    this.id,
    required this.name,
    required this.nameAr,
    this.isRequired = false,
    required this.options,
  });

  factory MenuVariation.fromJson(Map<String, dynamic> json) {
    return MenuVariation(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      isRequired: json['isRequired'] ?? false,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => VariationOption.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'nameAr': nameAr,
      'isRequired': isRequired,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  MenuVariation copyWith({
    String? id,
    String? name,
    String? nameAr,
    bool? isRequired,
    List<VariationOption>? options,
  }) {
    return MenuVariation(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
    );
  }
}

/// Menu category model
class MenuCategory {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final int itemCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.image,
    this.sortOrder = 0,
    this.isActive = true,
    this.itemCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      image: json['image'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      itemCount: json['itemCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'image': image,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  MenuCategory copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? image,
    int? sortOrder,
    bool? isActive,
    int? itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      image: image ?? this.image,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Menu item model
class MenuItem {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String? categoryNameAr;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final double price;
  final double? discountPrice;
  final DateTime? discountEndsAt;
  final int? preparationTime;
  final int? calories;
  final String? servingSize;
  final List<MenuAddon> addons;
  final List<MenuVariation> variations;
  final bool isAvailable;
  final bool isPopular;
  final bool isNewItem;
  final List<String> tags;
  final int sortOrder;
  final int totalOrders;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.id,
    required this.categoryId,
    this.categoryName,
    this.categoryNameAr,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.image,
    required this.price,
    this.discountPrice,
    this.discountEndsAt,
    this.preparationTime,
    this.calories,
    this.servingSize,
    this.addons = const [],
    this.variations = const [],
    this.isAvailable = true,
    this.isPopular = false,
    this.isNewItem = false,
    this.tags = const [],
    this.sortOrder = 0,
    this.totalOrders = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final categoryData = json['categoryId'];
    String categoryId = '';
    String? categoryName;
    String? categoryNameAr;

    if (categoryData is Map<String, dynamic>) {
      categoryId = categoryData['_id'] ?? categoryData['id'] ?? '';
      categoryName = categoryData['name'];
      categoryNameAr = categoryData['nameAr'];
    } else if (categoryData is String) {
      categoryId = categoryData;
    }

    return MenuItem(
      id: json['_id'] ?? json['id'] ?? '',
      categoryId: categoryId,
      categoryName: categoryName,
      categoryNameAr: categoryNameAr,
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      image: json['image'],
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      discountEndsAt: json['discountEndsAt'] != null
          ? DateTime.tryParse(json['discountEndsAt'])
          : null,
      preparationTime: json['preparationTime'],
      calories: json['calories'],
      servingSize: json['servingSize'],
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => MenuAddon.fromJson(e))
              .toList() ??
          [],
      variations: (json['variations'] as List<dynamic>?)
              ?.map((e) => MenuVariation.fromJson(e))
              .toList() ??
          [],
      isAvailable: json['isAvailable'] ?? true,
      isPopular: json['isPopular'] ?? false,
      isNewItem: json['isNewItem'] ?? json['isNew'] ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sortOrder: json['sortOrder'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'image': image,
      'price': price,
      'discountPrice': discountPrice,
      'discountEndsAt': discountEndsAt?.toIso8601String(),
      'preparationTime': preparationTime,
      'calories': calories,
      'servingSize': servingSize,
      'addons': addons.map((e) => e.toJson()).toList(),
      'variations': variations.map((e) => e.toJson()).toList(),
      'isAvailable': isAvailable,
      'isPopular': isPopular,
      'isNewItem': isNewItem,
      'tags': tags,
      'sortOrder': sortOrder,
    };
  }

  MenuItem copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? categoryNameAr,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? image,
    double? price,
    double? discountPrice,
    DateTime? discountEndsAt,
    int? preparationTime,
    int? calories,
    String? servingSize,
    List<MenuAddon>? addons,
    List<MenuVariation>? variations,
    bool? isAvailable,
    bool? isPopular,
    bool? isNewItem,
    List<String>? tags,
    int? sortOrder,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryNameAr: categoryNameAr ?? this.categoryNameAr,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      image: image ?? this.image,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      discountEndsAt: discountEndsAt ?? this.discountEndsAt,
      preparationTime: preparationTime ?? this.preparationTime,
      calories: calories ?? this.calories,
      servingSize: servingSize ?? this.servingSize,
      addons: addons ?? this.addons,
      variations: variations ?? this.variations,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      isNewItem: isNewItem ?? this.isNewItem,
      tags: tags ?? this.tags,
      sortOrder: sortOrder ?? this.sortOrder,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if item has active discount
  bool get hasDiscount {
    return discountPrice != null &&
        discountEndsAt != null &&
        discountEndsAt!.isAfter(DateTime.now());
  }

  /// Get current effective price
  double get currentPrice {
    if (hasDiscount) {
      return discountPrice!;
    }
    return price;
  }
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  bool get hasMore => page < pages;
}

/// Menu service for CRUD operations
class MenuService {
  final ApiService _apiService;

  MenuService(this._apiService);

  // ==================== Categories ====================

  /// Get all categories
  Future<List<MenuCategory>> getCategories() async {
    try {
      final response = await _apiService.get(AppEndpoints.menuCategories);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MenuCategory.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'فشل تحميل الأقسام');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Get category by ID
  Future<MenuCategory> getCategoryById(String categoryId) async {
    try {
      final response =
          await _apiService.get('${AppEndpoints.menuCategories}/$categoryId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuCategory.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'القسم غير موجود');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Create a new category
  Future<MenuCategory> createCategory({
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    bool isActive = true,
  }) async {
    try {
      Response response;
      if (imagePath != null) {
        response = await _apiService.uploadFile(
          AppEndpoints.menuCategories,
          filePath: imagePath,
          fieldName: 'image',
          additionalFields: {
            'name': name,
            'nameAr': nameAr,
            if (description != null) 'description': description,
            if (descriptionAr != null) 'descriptionAr': descriptionAr,
            'isActive': isActive,
          },
        );
      } else {
        response = await _apiService.post(
          AppEndpoints.menuCategories,
          data: {
            'name': name,
            'nameAr': nameAr,
            if (description != null) 'description': description,
            if (descriptionAr != null) 'descriptionAr': descriptionAr,
            'isActive': isActive,
          },
        );
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return MenuCategory.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل إنشاء القسم');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Update a category
  Future<MenuCategory> updateCategory({
    required String categoryId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    bool? isActive,
  }) async {
    try {
      Response response;
      if (imagePath != null) {
        response = await _apiService.uploadFile(
          '${AppEndpoints.menuCategories}/$categoryId',
          filePath: imagePath,
          fieldName: 'image',
          additionalFields: {
            if (name != null) 'name': name,
            if (nameAr != null) 'nameAr': nameAr,
            if (description != null) 'description': description,
            if (descriptionAr != null) 'descriptionAr': descriptionAr,
            if (isActive != null) 'isActive': isActive,
          },
        );
      } else {
        response = await _apiService.patch(
          '${AppEndpoints.menuCategories}/$categoryId',
          data: {
            if (name != null) 'name': name,
            if (nameAr != null) 'nameAr': nameAr,
            if (description != null) 'description': description,
            if (descriptionAr != null) 'descriptionAr': descriptionAr,
            if (isActive != null) 'isActive': isActive,
          },
        );
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuCategory.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل تحديث القسم');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response =
          await _apiService.delete('${AppEndpoints.menuCategories}/$categoryId');
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل حذف القسم');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Reorder categories
  Future<List<MenuCategory>> reorderCategories(
      List<Map<String, dynamic>> orderedCategories) async {
    try {
      final response = await _apiService.patch(
        '${AppEndpoints.menuCategories}/reorder',
        data: {'categories': orderedCategories},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => MenuCategory.fromJson(json)).toList();
      }
      throw Exception(response.data['message'] ?? 'فشل إعادة ترتيب الأقسام');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  // ==================== Menu Items ====================

  /// Get menu items with optional filters
  Future<PaginatedResult<MenuItem>> getMenuItems({
    String? categoryId,
    bool? isAvailable,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _apiService.get(
        AppEndpoints.menuItems,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> items = data is List ? data : (data['data'] ?? []);
        final pagination = data is Map ? data['pagination'] : null;

        return PaginatedResult(
          data: items.map((json) => MenuItem.fromJson(json)).toList(),
          page: pagination?['page'] ?? page,
          limit: pagination?['limit'] ?? limit,
          total: pagination?['total'] ?? items.length,
          pages: pagination?['pages'] ?? 1,
        );
      }
      throw Exception(response.data['message'] ?? 'فشل تحميل الأصناف');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Get menu item by ID
  Future<MenuItem> getMenuItemById(String itemId) async {
    try {
      final response =
          await _apiService.get('${AppEndpoints.menuItems}/$itemId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'الصنف غير موجود');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Create a new menu item
  Future<MenuItem> createMenuItem({
    required String categoryId,
    required String name,
    required String nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    required double price,
    double? discountPrice,
    DateTime? discountEndsAt,
    int? preparationTime,
    int? calories,
    String? servingSize,
    List<MenuAddon>? addons,
    List<MenuVariation>? variations,
    bool isAvailable = true,
    bool isPopular = false,
    bool isNewItem = true,
    List<String>? tags,
  }) async {
    try {
      final itemData = {
        'categoryId': categoryId,
        'name': name,
        'nameAr': nameAr,
        if (description != null) 'description': description,
        if (descriptionAr != null) 'descriptionAr': descriptionAr,
        'price': price,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (discountEndsAt != null)
          'discountEndsAt': discountEndsAt.toIso8601String(),
        if (preparationTime != null) 'preparationTime': preparationTime,
        if (calories != null) 'calories': calories,
        if (servingSize != null) 'servingSize': servingSize,
        if (addons != null && addons.isNotEmpty)
          'addons': addons.map((e) => e.toJson()).toList(),
        if (variations != null && variations.isNotEmpty)
          'variations': variations.map((e) => e.toJson()).toList(),
        'isAvailable': isAvailable,
        'isPopular': isPopular,
        'isNewItem': isNewItem,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      };

      Response response;
      if (imagePath != null) {
        response = await _apiService.uploadFile(
          AppEndpoints.menuItems,
          filePath: imagePath,
          fieldName: 'image',
          additionalFields: itemData,
        );
      } else {
        response = await _apiService.post(
          AppEndpoints.menuItems,
          data: itemData,
        );
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return MenuItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل إنشاء الصنف');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Update a menu item
  Future<MenuItem> updateMenuItem({
    required String itemId,
    String? categoryId,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? imagePath,
    double? price,
    double? discountPrice,
    DateTime? discountEndsAt,
    int? preparationTime,
    int? calories,
    String? servingSize,
    List<MenuAddon>? addons,
    List<MenuVariation>? variations,
    bool? isAvailable,
    bool? isPopular,
    bool? isNewItem,
    List<String>? tags,
  }) async {
    try {
      final itemData = <String, dynamic>{
        if (categoryId != null) 'categoryId': categoryId,
        if (name != null) 'name': name,
        if (nameAr != null) 'nameAr': nameAr,
        if (description != null) 'description': description,
        if (descriptionAr != null) 'descriptionAr': descriptionAr,
        if (price != null) 'price': price,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (discountEndsAt != null)
          'discountEndsAt': discountEndsAt.toIso8601String(),
        if (preparationTime != null) 'preparationTime': preparationTime,
        if (calories != null) 'calories': calories,
        if (servingSize != null) 'servingSize': servingSize,
        if (addons != null) 'addons': addons.map((e) => e.toJson()).toList(),
        if (variations != null)
          'variations': variations.map((e) => e.toJson()).toList(),
        if (isAvailable != null) 'isAvailable': isAvailable,
        if (isPopular != null) 'isPopular': isPopular,
        if (isNewItem != null) 'isNewItem': isNewItem,
        if (tags != null) 'tags': tags,
      };

      Response response;
      if (imagePath != null) {
        response = await _apiService.uploadFile(
          '${AppEndpoints.menuItems}/$itemId',
          filePath: imagePath,
          fieldName: 'image',
          additionalFields: itemData,
        );
      } else {
        response = await _apiService.patch(
          '${AppEndpoints.menuItems}/$itemId',
          data: itemData,
        );
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل تحديث الصنف');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Delete a menu item
  Future<void> deleteMenuItem(String itemId) async {
    try {
      final response =
          await _apiService.delete('${AppEndpoints.menuItems}/$itemId');
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل حذف الصنف');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Toggle item availability
  Future<MenuItem> toggleItemAvailability({
    required String itemId,
    required bool isAvailable,
  }) async {
    try {
      final response = await _apiService.patch(
        '${AppEndpoints.menuItems}/$itemId/availability',
        data: {'isAvailable': isAvailable},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return MenuItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل تحديث حالة الصنف');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Duplicate a menu item
  Future<MenuItem> duplicateMenuItem(String itemId) async {
    try {
      final response = await _apiService.post(
        '${AppEndpoints.menuItems}/$itemId/duplicate',
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return MenuItem.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'فشل نسخ الصنف');
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }

  /// Bulk update items
  Future<void> bulkUpdateItems(
      List<Map<String, dynamic>> itemUpdates) async {
    try {
      final response = await _apiService.patch(
        '${AppEndpoints.menuItems}/bulk',
        data: {'items': itemUpdates},
      );
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل تحديث الأصناف');
      }
    } on DioException catch (e) {
      throw Exception(_apiService.handleError(e));
    }
  }
}
