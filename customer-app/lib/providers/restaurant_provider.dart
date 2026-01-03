import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../services/api_service.dart';

part 'restaurant_provider.freezed.dart';

// Restaurant Service Provider
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RestaurantService(api);
});

// Featured Restaurants State
@freezed
class FeaturedRestaurantsState with _$FeaturedRestaurantsState {
  const factory FeaturedRestaurantsState({
    @Default([]) List<Restaurant> restaurants,
    @Default(false) bool isLoading,
    String? error,
  }) = _FeaturedRestaurantsState;
}

// Featured Restaurants Notifier
class FeaturedRestaurantsNotifier
    extends StateNotifier<FeaturedRestaurantsState> {
  final RestaurantService _service;

  FeaturedRestaurantsNotifier(this._service)
      : super(const FeaturedRestaurantsState()) {
    fetchFeatured();
  }

  Future<void> fetchFeatured() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.getFeaturedRestaurants();

    if (result.success) {
      state = state.copyWith(
        restaurants: result.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
    }
  }

  Future<void> refresh() async {
    await fetchFeatured();
  }
}

final featuredRestaurantsProvider = StateNotifierProvider<
    FeaturedRestaurantsNotifier, FeaturedRestaurantsState>((ref) {
  final service = ref.watch(restaurantServiceProvider);
  return FeaturedRestaurantsNotifier(service);
});

// Nearby Restaurants State
@freezed
class NearbyRestaurantsState with _$NearbyRestaurantsState {
  const factory NearbyRestaurantsState({
    @Default([]) List<Restaurant> restaurants,
    @Default(false) bool isLoading,
    String? error,
    double? lat,
    double? lng,
  }) = _NearbyRestaurantsState;
}

// Nearby Restaurants Notifier
class NearbyRestaurantsNotifier extends StateNotifier<NearbyRestaurantsState> {
  final RestaurantService _service;

  NearbyRestaurantsNotifier(this._service)
      : super(const NearbyRestaurantsState());

  Future<void> fetchNearby({
    required double lat,
    required double lng,
    double maxDistance = 10,
  }) async {
    state = state.copyWith(isLoading: true, error: null, lat: lat, lng: lng);

    final result = await _service.getNearbyRestaurants(
      lat: lat,
      lng: lng,
      maxDistance: maxDistance,
    );

    if (result.success) {
      state = state.copyWith(
        restaurants: result.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
    }
  }

  Future<void> refresh() async {
    if (state.lat != null && state.lng != null) {
      await fetchNearby(lat: state.lat!, lng: state.lng!);
    }
  }
}

final nearbyRestaurantsProvider =
    StateNotifierProvider<NearbyRestaurantsNotifier, NearbyRestaurantsState>(
        (ref) {
  final service = ref.watch(restaurantServiceProvider);
  return NearbyRestaurantsNotifier(service);
});

// Search State
@freezed
class RestaurantSearchState with _$RestaurantSearchState {
  const factory RestaurantSearchState({
    @Default([]) List<Restaurant> restaurants,
    @Default(false) bool isLoading,
    String? error,
    @Default(1) int currentPage,
    @Default(1) int totalPages,
    @Default(false) bool hasMore,
    RestaurantSearchParams? params,
  }) = _RestaurantSearchState;
}

// Search Notifier
class RestaurantSearchNotifier extends StateNotifier<RestaurantSearchState> {
  final RestaurantService _service;

  RestaurantSearchNotifier(this._service)
      : super(const RestaurantSearchState());

  Future<void> search(RestaurantSearchParams params) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      params: params,
      restaurants: params.page == 1 ? [] : state.restaurants,
    );

    final result = await _service.searchRestaurants(params);

    if (result.success) {
      final newRestaurants = params.page == 1
          ? result.data ?? []
          : [...state.restaurants, ...result.data ?? []];

      state = state.copyWith(
        restaurants: newRestaurants,
        isLoading: false,
        currentPage: result.pagination?.page ?? params.page,
        totalPages: result.pagination?.pages ?? 1,
        hasMore: (result.pagination?.page ?? 1) <
            (result.pagination?.pages ?? 1),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.params == null) return;

    await search(state.params!.copyWith(page: state.currentPage + 1));
  }

  void clear() {
    state = const RestaurantSearchState();
  }
}

final restaurantSearchProvider =
    StateNotifierProvider<RestaurantSearchNotifier, RestaurantSearchState>(
        (ref) {
  final service = ref.watch(restaurantServiceProvider);
  return RestaurantSearchNotifier(service);
});

// Restaurant Details State
@freezed
class RestaurantDetailsState with _$RestaurantDetailsState {
  const factory RestaurantDetailsState({
    Restaurant? restaurant,
    @Default([]) List<MenuCategory> menu,
    @Default(false) bool isLoading,
    String? error,
  }) = _RestaurantDetailsState;
}

// Restaurant Details Notifier
class RestaurantDetailsNotifier extends StateNotifier<RestaurantDetailsState> {
  final RestaurantService _service;

  RestaurantDetailsNotifier(this._service)
      : super(const RestaurantDetailsState());

  Future<void> fetchRestaurant(String slug) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.getRestaurantBySlug(slug);

    if (result.success && result.data != null) {
      state = state.copyWith(
        restaurant: result.data,
        isLoading: false,
      );

      // Fetch menu
      await fetchMenu(slug);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
    }
  }

  Future<void> fetchMenu(String slug) async {
    final result = await _service.getRestaurantMenu(slug);

    if (result.success) {
      state = state.copyWith(menu: result.data ?? []);
    }
  }

  Future<void> toggleFavorite() async {
    if (state.restaurant == null) return;

    final result = await _service.toggleFavorite(state.restaurant!.id);

    if (result.success) {
      state = state.copyWith(
        restaurant: state.restaurant!.copyWith(isFavorite: result.data ?? false),
      );
    }
  }
}

final restaurantDetailsProvider =
    StateNotifierProvider<RestaurantDetailsNotifier, RestaurantDetailsState>(
        (ref) {
  final service = ref.watch(restaurantServiceProvider);
  return RestaurantDetailsNotifier(service);
});

// Favorites State
@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState({
    @Default([]) List<Restaurant> restaurants,
    @Default(false) bool isLoading,
    String? error,
  }) = _FavoritesState;
}

// Favorites Notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final RestaurantService _service;

  FavoritesNotifier(this._service) : super(const FavoritesState());

  Future<void> fetchFavorites() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.getFavorites();

    if (result.success) {
      state = state.copyWith(
        restaurants: result.data ?? [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.message,
      );
    }
  }

  Future<void> toggleFavorite(String restaurantId) async {
    final result = await _service.toggleFavorite(restaurantId);

    if (result.success) {
      if (result.data == false) {
        // Removed from favorites
        state = state.copyWith(
          restaurants: state.restaurants
              .where((r) => r.id != restaurantId)
              .toList(),
        );
      } else {
        // Refresh to get full data
        await fetchFavorites();
      }
    }
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final service = ref.watch(restaurantServiceProvider);
  return FavoritesNotifier(service);
});
