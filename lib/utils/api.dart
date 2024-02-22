class Api {
  static const String baseUrl = '192.168.181.129:5000';
  static const String loginUrl = 'http://$baseUrl/api/login';
  static const String signupPath = '/api/signup';
  static const String forgotPasswordUrl = 'http://$baseUrl/api/forgot-password';
  static const String addCatchUrl = 'http://$baseUrl/api/seller/add-catch';
  static const String sellerCatchesUrl = 'http://$baseUrl/api/seller/catches';
  static const String catchesUrl = 'http://$baseUrl/api/catches';
  static const String deleteCatchUrl =
      'http://$baseUrl/api/seller/delete-catch';
  static const String editCatchUrl = 'http://$baseUrl/api/seller/edit-catch';
}
