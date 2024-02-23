class Api {
  static const String baseUrl = 'https://fishlink-server.onrender.com';
  static const String loginUrl = '$baseUrl/api/login';
  static const String signupPath = '$baseUrl/api/signup';
  static const String forgotPasswordUrl = '$baseUrl/api/forgot-password';
  static const String addCatchUrl = '$baseUrl/api/seller/add-catch';
  static const String sellerCatchesUrl = '$baseUrl/api/seller/catches';
  static const String catchesUrl = '$baseUrl/api/catches';
  static const String deleteCatchUrl = '$baseUrl/api/seller/delete-catch';
  static const String editCatchUrl = '$baseUrl/api/seller/edit-catch';
}
