/// API Configuration Template
/// 
/// IMPORTANT: Copy this file to `api_config.dart` and fill in your actual credentials.
/// The `api_config.dart` file is in `.gitignore` and will NOT be committed to version control.
/// 
/// Contains all API keys, URLs, and credentials for third-party services
class ApiConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  static const String supabaseSecretKey =
      'YOUR_SUPABASE_SECRET_KEY_HERE'; // For server-side use only

  // TinyPesa (M-Pesa API) Configuration
  static const String tinypesaUsername = 'YOUR_TINYPESA_USERNAME_HERE';
  static const String tinypesaApiKey = 'YOUR_TINYPESA_API_KEY_HERE';
  static const String tinypesaBaseUrl =
      'https://tinypesa.com/api/v1'; // TinyPesa API base URL

  // OpenAI GPT Configuration
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY_HERE';

  // Google Calendar OAuth2 Configuration
  static const String googleClientId = 'YOUR_GOOGLE_CLIENT_ID_HERE';

  // Payment Gateway Endpoints
  static String getTinypesaStkPushUrl() {
    return '$tinypesaBaseUrl/express/initialize';
  }

  static String getTinypesaStatusUrl(String checkoutRequestId) {
    return '$tinypesaBaseUrl/express/status/$checkoutRequestId';
  }

  // Headers for API requests
  static Map<String, String> getTinypesaHeaders() {
    return {
      'ApiKey': tinypesaApiKey,
      'Content-Type': 'application/json',
    };
  }
}

