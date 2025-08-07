class Endpoint {
  //auth
  static const String authLoginUrl = '/api/login';
  static const String authRegisterUrl = '/api/register';
  static const String logoutUrl = '/api/logout';

  // service
  static const String kecamatanUrl = '/api/service/kecamatan';
  static const String kelurahanUrl = '/api/service/kelurahan';

  // user
  static const String userProfileUrl = '/api/user';

  //product
  static const String productUrl = '/api/products';

  // bengkel
  static const String listBengkelUrl = '/api/bengkel/list';
  static const String bengkelUrl = '/api/bengkel';

  //cart
  static const String cartUrl = '/api/cart';

  // booking
  static const String bookingUrl = '/api/booking';
  static const String userBookingUrl = '/api/user/bookings';

  //checkout
  static const String checkoutSummary = '/api/checkout-summary';
  static const String checkoutUrl = '/api/checkout';
}