class Endpoint {
  //auth
  static const String authLoginUrl = '/api/login';
  static const String authRegisterUrl = '/api/register';
  static const String logoutUrl = '/api/logout';

  // forgot password
  static const String sendOtpUrl = '/api/user/forgot-password/send-otp';
  static const String verifyOtpUrl = '/api/user/forgot-password/verify-otp';
  static const String resetPasswordUrl =
      '/api/user/forgot-password/reset-password';

  // service
  static const String kecamatanUrl = '/api/service/kecamatan';
  static const String kelurahanUrl = '/api/service/kelurahan';

  // user
  static const String userProfileUrl = '/api/user';

  //product
  static const String productUrl = '/api/products';

  // category
  static const String categoryUrl = '/api/categories';

  // bengkel
  static const String listBengkelUrl = '/api/bengkel/list';
  static const String bengkelUrl = '/api/bengkel';
  static const String bengkelNearbyUrl = '/api/bengkel/nearby';

  // specialist
  static const String specialistUrl = '/api/specialists';

  // merk mobil
  static const String merkMobilUrl = '/api/merk-mobil';

  //cart
  static const String cartUrl = '/api/cart';

  // booking
  static const String bookingUrl = '/api/booking';
  static const String userBookingUrl = '/api/user/bookings';

  //checkout
  static const String checkoutSummary = '/api/checkout-summary';
  static const String checkoutUrl = '/api/checkout';

  // transaction
  static const String transactionUrl = '/api/profile/transactions';

  // rating
  static const String ratingUrl = '/api/ratings';
  static const String chatUrl = '/api/chat/send';
}
