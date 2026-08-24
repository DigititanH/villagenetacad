/// Locked month-end split of each attributed sale (100%).
class RevenueSplit {
  static const double beneficiaryPercent = 53;
  static const double centrePercent = 26;
  static const double digititanPercent = 21;

  static double beneficiaryShare(double orderTotal) =>
      orderTotal * (beneficiaryPercent / 100);
  static double centreShare(double orderTotal) =>
      orderTotal * (centrePercent / 100);
  static double digititanShare(double orderTotal) =>
      orderTotal * (digititanPercent / 100);
}
