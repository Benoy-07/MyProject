import '../models/loyalty_model.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';

class LoyaltyService {
  // Calculate points earned from a booking
  static int calculatePointsFromBooking(Booking booking, LoyaltyProgram program) {
    int points = 0;
    
    // Points per meal
    points += booking.totalQuantity * program.pointsPerMeal;
    
    // Points per taka spent
    points += (booking.totalAmount * program.pointsPerTaka).floor();
    
    return points;
  }

  // Calculate discount from loyalty points
  static double calculateDiscountFromPoints(int points, LoyaltyProgram program) {
    if (points < program.minPointsForRedemption) {
      return 0.0;
    }
    
    final usablePoints = points.clamp(0, program.maxRedemptionPerOrder);
    return usablePoints * program.discountPerPoint;
  }

  // Check if user can redeem points
  static bool canRedeemPoints(int points, LoyaltyProgram program) {
    return points >= program.minPointsForRedemption;
  }

  // Calculate new loyalty tier based on total points
  static LoyaltyTier calculateLoyaltyTier(int totalPoints) {
    if (totalPoints >= 5000) return LoyaltyTier.platinum;
    if (totalPoints >= 2000) return LoyaltyTier.gold;
    if (totalPoints >= 500) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  // Get tier benefits description
  static String getTierBenefits(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Earn 1 point per taka spent';
      case LoyaltyTier.silver:
        return 'Earn 1.5 points per taka spent + Priority booking';
      case LoyaltyTier.gold:
        return 'Earn 2 points per taka spent + Priority booking + Free delivery';
      case LoyaltyTier.platinum:
        return 'Earn 3 points per taka spent + All Gold benefits + Exclusive events';
    }
  }

  // Calculate points needed for next tier
  static int pointsToNextTier(int currentPoints, LoyaltyTier currentTier) {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 500 - currentPoints;
      case LoyaltyTier.silver:
        return 2000 - currentPoints;
      case LoyaltyTier.gold:
        return 5000 - currentPoints;
      case LoyaltyTier.platinum:
        return 0; // Already at highest tier
    }
  }
}