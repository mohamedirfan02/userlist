/// Contains all the base API endpoints used in the app.
/// Centralizing API URLs here makes it easier to switch environments.
class AppApiConstants {
  // Base API URL for Address endpoints
  static const String baseUrl = 'https://690c70dfa6d92d83e84dc0a3.mockapi.io/api/users';

  // Address endpoints
  static const String addressesEndpoint = '$baseUrl/users';

// static const String authEndpoint = '$baseUrl/auth';
// static const String profileEndpoint = '$baseUrl/profile';
}
