import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../models/address.dart';
import '../services/api_service.dart';

/// Address list state
class AddressListState {
  final List<Address> addresses;
  final bool isLoading;
  final String? error;

  const AddressListState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
  });

  AddressListState copyWith({
    List<Address>? addresses,
    bool? isLoading,
    String? error,
  }) {
    return AddressListState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Address? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }
}

/// Address list notifier
class AddressListNotifier extends StateNotifier<AddressListState> {
  final ApiService _apiService;

  AddressListNotifier(this._apiService) : super(const AddressListState()) {
    fetchAddresses();
  }

  /// Fetch all addresses
  Future<void> fetchAddresses() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(AppEndpoints.addresses);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> addressesJson = response.data['data'] ?? [];
        final addresses =
            addressesJson.map((json) => Address.fromJson(json)).toList();

        state = state.copyWith(
          addresses: addresses,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل جلب العناوين',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  /// Add a new address
  Future<Address?> addAddress(AddressInput input) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post(
        AppEndpoints.addresses,
        data: input.toJson(),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final newAddress = Address.fromJson(response.data['data']);

        // If this address is default, update other addresses
        List<Address> updatedAddresses;
        if (newAddress.isDefault) {
          updatedAddresses = state.addresses
              .map((a) => a.copyWith(isDefault: false))
              .toList();
        } else {
          updatedAddresses = List.from(state.addresses);
        }
        updatedAddresses.add(newAddress);

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
        );

        return newAddress;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل إضافة العنوان',
        );
        return null;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }

  /// Update an existing address
  Future<Address?> updateAddress(String addressId, AddressInput input) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.put(
        '${AppEndpoints.addresses}/$addressId',
        data: input.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAddress = Address.fromJson(response.data['data']);

        // Update addresses list
        List<Address> updatedAddresses;
        if (updatedAddress.isDefault) {
          // If this is now default, unset others
          updatedAddresses = state.addresses.map((a) {
            if (a.id == addressId) {
              return updatedAddress;
            }
            return a.copyWith(isDefault: false);
          }).toList();
        } else {
          updatedAddresses = state.addresses.map((a) {
            if (a.id == addressId) {
              return updatedAddress;
            }
            return a;
          }).toList();
        }

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
        );

        return updatedAddress;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل تحديث العنوان',
        );
        return null;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return null;
    }
  }

  /// Delete an address
  Future<bool> deleteAddress(String addressId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.delete(
        '${AppEndpoints.addresses}/$addressId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final deletedWasDefault =
            state.addresses.firstWhere((a) => a.id == addressId).isDefault;

        var updatedAddresses =
            state.addresses.where((a) => a.id != addressId).toList();

        // If deleted was default, set first as new default
        if (deletedWasDefault && updatedAddresses.isNotEmpty) {
          updatedAddresses = [
            updatedAddresses.first.copyWith(isDefault: true),
            ...updatedAddresses.skip(1),
          ];
        }

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل حذف العنوان',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Set an address as default
  Future<bool> setDefaultAddress(String addressId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.patch(
        '${AppEndpoints.addresses}/$addressId/default',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final updatedAddresses = state.addresses.map((a) {
          return a.copyWith(isDefault: a.id == addressId);
        }).toList();

        state = state.copyWith(
          addresses: updatedAddresses,
          isLoading: false,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل تعيين العنوان كافتراضي',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh addresses
  Future<void> refresh() async {
    await fetchAddresses();
  }
}

/// Address list provider
final addressListProvider =
    StateNotifierProvider<AddressListNotifier, AddressListState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AddressListNotifier(apiService);
});

/// Selected address provider (for checkout)
final selectedAddressProvider = StateProvider<Address?>((ref) {
  final addressState = ref.watch(addressListProvider);
  return addressState.defaultAddress;
});

/// Default address provider
final defaultAddressProvider = Provider<Address?>((ref) {
  final addressState = ref.watch(addressListProvider);
  return addressState.defaultAddress;
});

/// Has addresses provider
final hasAddressesProvider = Provider<bool>((ref) {
  final addressState = ref.watch(addressListProvider);
  return addressState.addresses.isNotEmpty;
});

/// Address count provider
final addressCountProvider = Provider<int>((ref) {
  final addressState = ref.watch(addressListProvider);
  return addressState.addresses.length;
});
