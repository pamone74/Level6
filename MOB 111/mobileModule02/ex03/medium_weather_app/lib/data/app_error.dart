enum AppErrorCategory {
  emptySearch,
  locationNotFound,
  geocoding,
  weather,
  locationServiceDisabled,
  locationPermissionDenied,
  locationPermissionDeniedForever,
  locationRetrieval,
}

class AppError {
  const AppError({
    required this.category,
    required this.message,
    this.technicalDetail,
  });
  final AppErrorCategory category;
  final String message;
  final String? technicalDetail;

  bool get isSearchError => switch (category) {
    AppErrorCategory.emptySearch ||
    AppErrorCategory.locationNotFound ||
    AppErrorCategory.geocoding => true,
    _ => false,
  };
}
