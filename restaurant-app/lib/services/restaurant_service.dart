import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import 'api_service.dart';

/// Restaurant profile data model
class RestaurantProfile {
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String? descriptionAr;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final String? email;
  final String? address;
  final Map<String, dynamic>? location;
  final List<String> cuisineTypes;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final bool isActive;
  final Map<String, OpeningHours>? openingHours;
  final DeliverySettings? deliverySettings;
  final BankDetails? bankDetails;
  final DateTime? createdAt;

  RestaurantProfile({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.descriptionAr,
    this.logo,
    this.coverImage,
    this.phone,
    this.email,
    this.address,
    this.location,
    this.cuisineTypes = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isOpen = false,
    this.isActive = true,
    this.openingHours,
    this.deliverySettings,
    this.bankDetails,
    this.createdAt,
  });

  factory RestaurantProfile.fromJson(Map<String, dynamic> json) {
    Map<String, OpeningHours>? hours;
    if (json['openingHours'] != null) {
      hours = {};
      (json['openingHours'] as Map<String, dynamic>).forEach((key, value) {
        hours![key] = OpeningHours.fromJson(value);
      });
    }

    return RestaurantProfile(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? json['name'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      logo: json['logo'],
      coverImage: json['coverImage'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      location: json['location'],
      cuisineTypes: List<String>.from(json['cuisineTypes'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isOpen: json['isOpen'] ?? false,
      isActive: json['isActive'] ?? true,
      openingHours: hours,
      deliverySettings: json['deliverySettings'] != null
          ? DeliverySettings.fromJson(json['deliverySettings'])
          : null,
      bankDetails: json['bankDetails'] != null
          ? BankDetails.fromJson(json['bankDetails'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'nameAr': nameAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'phone': phone,
        'email': email,
        'address': address,
        'cuisineTypes': cuisineTypes,
        if (openingHours != null)
          'openingHours': openingHours!.map((k, v) => MapEntry(k, v.toJson())),
        if (deliverySettings != null)
          'deliverySettings': deliverySettings!.toJson(),
        if (bankDetails != null) 'bankDetails': bankDetails!.toJson(),
      };
}

/// Opening hours for a day
class OpeningHours {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;

  OpeningHours({
    this.isOpen = false,
    this.openTime,
    this.closeTime,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      isOpen: json['isOpen'] ?? false,
      openTime: json['openTime'],
      closeTime: json['closeTime'],
    );
  }

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        'openTime': openTime,
        'closeTime': closeTime,
      };
}

/// Delivery settings
class DeliverySettings {
  final double deliveryFee;
  final double minimumOrder;
  final int estimatedDeliveryTime;
  final double deliveryRadius;
  final bool freeDeliveryEnabled;
  final double? freeDeliveryMinimum;

  DeliverySettings({
    this.deliveryFee = 0,
    this.minimumOrder = 0,
    this.estimatedDeliveryTime = 30,
    this.deliveryRadius = 5,
    this.freeDeliveryEnabled = false,
    this.freeDeliveryMinimum,
  });

  factory DeliverySettings.fromJson(Map<String, dynamic> json) {
    return DeliverySettings(
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      minimumOrder: (json['minimumOrder'] ?? 0).toDouble(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? 30,
      deliveryRadius: (json['deliveryRadius'] ?? 5).toDouble(),
      freeDeliveryEnabled: json['freeDeliveryEnabled'] ?? false,
      freeDeliveryMinimum: json['freeDeliveryMinimum']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deliveryFee': deliveryFee,
        'minimumOrder': minimumOrder,
        'estimatedDeliveryTime': estimatedDeliveryTime,
        'deliveryRadius': deliveryRadius,
        'freeDeliveryEnabled': freeDeliveryEnabled,
        'freeDeliveryMinimum': freeDeliveryMinimum,
      };
}

/// Bank details for payouts
class BankDetails {
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? iban;

  BankDetails({
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.iban,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      iban: json['iban'],
    );
  }

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'iban': iban,
      };
}

/// Restaurant service for profile and settings operations
class RestaurantService {
  final ApiService _api;

  RestaurantService(this._api);

  /// Get restaurant profile
  Future<RestaurantProfile> getProfile() async {
    try {
      final response = await _api.get(AppEndpoints.restaurantProfile);

      if (response.data['success'] == true) {
        return RestaurantProfile.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب بيانات المطعم');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update restaurant profile
  Future<RestaurantProfile> updateProfile({
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? phone,
    String? email,
    String? address,
    List<String>? cuisineTypes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (nameAr != null) data['nameAr'] = nameAr;
      if (description != null) data['description'] = description;
      if (descriptionAr != null) data['descriptionAr'] = descriptionAr;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (address != null) data['address'] = address;
      if (cuisineTypes != null) data['cuisineTypes'] = cuisineTypes;

      final response = await _api.put(
        AppEndpoints.restaurantProfile,
        data: data,
      );

      if (response.data['success'] == true) {
        return RestaurantProfile.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث بيانات المطعم');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update restaurant logo
  Future<String> updateLogo(String filePath) async {
    try {
      final response = await _api.uploadFile(
        '${AppEndpoints.restaurantProfile}/logo',
        filePath: filePath,
        fieldName: 'logo',
      );

      if (response.data['success'] == true) {
        return response.data['data']['logo'];
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث الشعار');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update restaurant cover image
  Future<String> updateCoverImage(String filePath) async {
    try {
      final response = await _api.uploadFile(
        '${AppEndpoints.restaurantProfile}/cover',
        filePath: filePath,
        fieldName: 'coverImage',
      );

      if (response.data['success'] == true) {
        return response.data['data']['coverImage'];
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث صورة الغلاف');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update opening hours
  Future<RestaurantProfile> updateOpeningHours(
      Map<String, OpeningHours> hours) async {
    try {
      final response = await _api.put(
        AppEndpoints.restaurantSettings,
        data: {
          'openingHours': hours.map((k, v) => MapEntry(k, v.toJson())),
        },
      );

      if (response.data['success'] == true) {
        return RestaurantProfile.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث ساعات العمل');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update delivery settings
  Future<RestaurantProfile> updateDeliverySettings(
      DeliverySettings settings) async {
    try {
      final response = await _api.put(
        AppEndpoints.restaurantSettings,
        data: {
          'deliverySettings': settings.toJson(),
        },
      );

      if (response.data['success'] == true) {
        return RestaurantProfile.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث إعدادات التوصيل');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update bank details
  Future<RestaurantProfile> updateBankDetails(BankDetails details) async {
    try {
      final response = await _api.put(
        AppEndpoints.restaurantSettings,
        data: {
          'bankDetails': details.toJson(),
        },
      );

      if (response.data['success'] == true) {
        return RestaurantProfile.fromJson(response.data['data']);
      }

      throw Exception(
          response.data['message'] ?? 'فشل في تحديث البيانات البنكية');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Toggle restaurant open/closed status
  Future<bool> toggleStatus(bool isOpen) async {
    try {
      final response = await _api.put(
        AppEndpoints.restaurantStatus,
        data: {'isOpen': isOpen},
      );

      if (response.data['success'] == true) {
        return response.data['data']['isOpen'] ?? isOpen;
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث الحالة');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }
    }
    return Exception('حدث خطأ ما');
  }
}

/// Restaurant service provider
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RestaurantService(apiService);
});

/// Restaurant profile state provider
final restaurantProfileProvider =
    FutureProvider.autoDispose<RestaurantProfile>((ref) async {
  final service = ref.watch(restaurantServiceProvider);
  return service.getProfile();
});
