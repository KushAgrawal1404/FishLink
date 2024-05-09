class Api {
  static const String baseUrl = 'http://34.100.135.239:8080';
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
  static const String fetchMyWins = '$baseUrl/api/catches/won';
  static const String userProfileUrl = '$baseUrl/api/userProfile';
  static const String updateBuyerRatedUrl = '$baseUrl/api/updateBuyerRated';
  static const String createSellerRatingUrl = '$baseUrl/api/ratings/sellers';
  static const String getSellerRatingsUrl = '$baseUrl/api/ratings/sellers';
  static const String catchSellerUrl = '$baseUrl/api/catch/seller';
  static const String winnerUrl = '$baseUrl/api/win';

  static String winDetailsUrl(String catchId) =>
      '$baseUrl/api/win_details/$catchId';

  // for chat
  static const String sendMessageUrl =
      '$baseUrl/api/sendMessage'; // New URL for sending messages
  static String getChatMessagesUrl(String senderId, String catchId) =>
      '$baseUrl/api/chat/$senderId/$catchId'; // New URL for fetching chat messages
}
