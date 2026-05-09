class AppConfig {
  static const String devBaseUrl = 'http://192.168.68.113:8080';
  static const String prodBaseUrl = 'https://api.cookest.app'; // Placeholder
  
  static String get baseUrl => devBaseUrl; // Switch logic here for flavors
  
  static const String apiPrefix = '/api';
  
  // Storage Keys
  static const String keyFirstTime = 'cookest_first_time';
  static const String keySessionFlag = 'cookest_logged_in';
}
