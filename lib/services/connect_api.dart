class ConnectApi {
  static const String rootUrl = 'https://fox-cymbal-sublet.ngrok-free.dev';
  static const String baseUrl = '$rootUrl/api';

  static String url(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }

  static String storageUrl(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$rootUrl/storage/$cleanPath';
  }
}