class Api {
  static const String baseUrl = 'http://172.16.251.106:5000';
  static const String loginUrl = '$baseUrl/api/login';
  static const String signupPath = '$baseUrl/api/signup';
  static const String forgotPasswordUrl = '$baseUrl/api/forgot-password';
  static const String addCatchUrl = '$baseUrl/api/seller/add-catch';
  static const String sellerCatchesUrl = '$baseUrl/api/seller/catches';
  static const String catchesUrl = '$baseUrl/api/catches';
  static const String deleteCatchUrl = '$baseUrl/api/seller/delete-catch';
  static const String editCatchUrl = '$baseUrl/api/seller/edit-catch';
  static const String placeBidUrl = '$baseUrl/api/placeBid';
  static const String catchDetailsUrl = '$baseUrl/api/catch';
  static const String fetchbids = '$baseUrl/api/my-bids';
  static const String createRatingUrl = '$baseUrl/api/ratings';
  static const String getRatingsByCatchIdUrl = '$baseUrl/api/ratings';
  static const String analyticsUrl = '$baseUrl/api/analytics';
  static const String userProfileUrl = '$baseUrl/api/userProfile';
  static const String updateBuyerRatedUrl = '$baseUrl/api/updateBuyerRated';
}
