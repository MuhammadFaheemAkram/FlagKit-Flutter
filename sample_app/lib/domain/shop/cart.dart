import 'package:flutter/foundation.dart';

/// A product in the demo's cart. Money is in whole cents: `int`, never
/// `double`, so totals never drift by a fraction of a cent.
@immutable
final class CartLine {
  const CartLine({
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
  });

  final String name;
  final int unitPriceCents;
  final int quantity;

  int get totalCents => unitPriceCents * quantity;

  @override
  bool operator ==(Object other) =>
      other is CartLine &&
      other.name == name &&
      other.unitPriceCents == unitPriceCents &&
      other.quantity == quantity;

  @override
  int get hashCode => Object.hash(name, unitPriceCents, quantity);
}

/// The cart's figures for a discount.
@immutable
final class CartTotals {
  const CartTotals({
    required this.subtotalCents,
    required this.discountPercent,
    required this.discountCents,
  });

  /// The totals of [lines] with [discountPercent] off (clamped to 0–100).
  factory CartTotals.of(List<CartLine> lines, double discountPercent) {
    final subtotal = lines.fold(0, (sum, line) => sum + line.totalCents);
    final percent = discountPercent.clamp(0.0, 100.0);
    return CartTotals(
      subtotalCents: subtotal,
      discountPercent: percent,
      discountCents: discountOf(subtotal, percent),
    );
  }

  final int subtotalCents;
  final double discountPercent;
  final int discountCents;

  int get totalCents => subtotalCents - discountCents;

  /// [percent] of [cents], rounded half up to a cent, in integers: the
  /// percent is taken to hundredths of a percent first, so 15.5 % of
  /// $74.50 is exactly $11.55 (1154.75 cents, rounded up), with no
  /// floating-point drift.
  static int discountOf(int cents, double percent) {
    final basisPoints = (percent * 100).round();
    return (cents * basisPoints + 5000) ~/ 10000;
  }

  @override
  bool operator ==(Object other) =>
      other is CartTotals &&
      other.subtotalCents == subtotalCents &&
      other.discountPercent == discountPercent &&
      other.discountCents == discountCents;

  @override
  int get hashCode =>
      Object.hash(subtotalCents, discountPercent, discountCents);
}

/// The demo's fixed cart: the checkout is about the flags, not shopping.
abstract final class DemoCart {
  static const lines = [
    CartLine(name: 'Coffee beans', unitPriceCents: 1250, quantity: 2),
    CartLine(name: 'Travel mug', unitPriceCents: 2400, quantity: 1),
    CartLine(name: 'Paper filters', unitPriceCents: 450, quantity: 3),
  ];
}
