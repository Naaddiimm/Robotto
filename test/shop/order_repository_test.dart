import 'package:flutter_test/flutter_test.dart';
import 'package:robotto/shop/data/repositories/order_repository.dart';
import 'package:robotto/shop/data/repositories/delivery_repository.dart';
import 'package:robotto/shop/data/models/order.dart';
import 'package:robotto/shop/data/models/order_item.dart';
import 'package:robotto/shop/data/models/delivery.dart';

/// Tests for OrderRepository and DeliveryRepository pure logic (no DB required).
///
/// Full repository DB tests (createOrder, updateOrderDetails, advanceStatus,
/// cancelOrder, deleteOrder) require sqflite_common_ffi for in-memory database
/// testing, which is not in dev_dependencies. To enable those tests, add
/// `sqflite_common_ffi` to dev_dependencies in pubspec.yaml.
void main() {
  group('OrderDetail', () {
    test('holds order, items, and delivery', () {
      final order = Order(
        id: 1,
        buyerId: 10,
        status: Order.statusPending,
        paymentMethod: Order.cashOnDelivery,
        subtotal: 50.0,
        deliveryFee: 7.0,
        total: 57.0,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
      final items = [
        OrderItem(
          id: 1,
          orderId: 1,
          productId: 5,
          sellerId: 20,
          productName: 'Arduino Uno',
          unitPrice: 50.0,
          quantity: 1,
        ),
      ];
      final delivery = Delivery(
        id: 1,
        orderId: 1,
        mode: Delivery.modeHome,
        recipientName: 'John Doe',
        phone: '12345678',
        address: '123 Main Street, Tunis',
        city: 'Tunis',
        zone: Delivery.zoneGrandTunis,
        totalWeightKg: 0.5,
        fee: 7.0,
        status: Order.statusPending,
        statusUpdatedAt: '2024-01-01T00:00:00.000',
      );
      final detail = OrderDetail(
        order: order,
        items: items,
        delivery: delivery,
      );
      expect(detail.order.id, 1);
      expect(detail.items.length, 1);
      expect(detail.items.first.productName, 'Arduino Uno');
      expect(detail.delivery?.mode, Delivery.modeHome);
    });

    test('delivery can be null', () {
      final order = Order(
        id: 1,
        buyerId: 10,
        status: Order.statusPending,
        paymentMethod: Order.cashOnDelivery,
        subtotal: 50.0,
        deliveryFee: 0,
        total: 50.0,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-01T00:00:00.000',
      );
      final detail = OrderDetail(order: order, items: []);
      expect(detail.delivery, isNull);
    });
  });

  group('OrderRepository instantiation', () {
    test('can be instantiated', () {
      expect(OrderRepository(), isNotNull);
    });
  });

  group('DeliveryRepository instantiation', () {
    test('can be instantiated', () {
      expect(DeliveryRepository(), isNotNull);
    });
  });

  group('Order model round-trip (used by repository)', () {
    test('toMap and fromMap preserves all fields', () {
      final order = Order(
        id: 42,
        buyerId: 7,
        status: Order.statusShipped,
        paymentMethod: Order.cashOnDelivery,
        subtotal: 100.0,
        deliveryFee: 15.0,
        total: 115.0,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-06-01T00:00:00.000',
      );
      final map = order.toMap();
      final restored = Order.fromMap(map);

      expect(restored.id, 42);
      expect(restored.buyerId, 7);
      expect(restored.status, Order.statusShipped);
      expect(restored.paymentMethod, Order.cashOnDelivery);
      expect(restored.subtotal, 100.0);
      expect(restored.deliveryFee, 15.0);
      expect(restored.total, 115.0);
    });
  });

  group('OrderItem model round-trip (used by repository)', () {
    test('toMap and fromMap preserves snapshot fields', () {
      final item = OrderItem(
        id: 1,
        orderId: 10,
        productId: 5,
        sellerId: 20,
        productName: 'Sensor Module',
        unitPrice: 25.50,
        quantity: 2,
      );
      final map = item.toMap();
      final restored = OrderItem.fromMap(map);
      expect(restored.id, 1);
      expect(restored.orderId, 10);
      expect(restored.productId, 5);
      expect(restored.sellerId, 20);
      expect(restored.productName, 'Sensor Module');
      expect(restored.unitPrice, 25.50);
      expect(restored.quantity, 2);
    });
  });

  group('Delivery model round-trip (used by repository)', () {
    test('toMap and fromMap preserves all fields', () {
      final delivery = Delivery(
        id: 1,
        orderId: 10,
        mode: Delivery.modeRelayPoint,
        recipientName: 'Jane Smith',
        phone: '87654321',
        address: '456 Avenue, Sfax',
        city: 'Sfax',
        zone: Delivery.zoneSouth,
        totalWeightKg: 2.5,
        fee: 15.0,
        status: Order.statusOutForDelivery,
        statusUpdatedAt: '2024-06-01T12:00:00.000',
      );
      final map = delivery.toMap();
      final restored = Delivery.fromMap(map);
      expect(restored.id, 1);
      expect(restored.orderId, 10);
      expect(restored.mode, Delivery.modeRelayPoint);
      expect(restored.recipientName, 'Jane Smith');
      expect(restored.phone, '87654321');
      expect(restored.zone, Delivery.zoneSouth);
      expect(restored.totalWeightKg, 2.5);
      expect(restored.fee, 15.0);
      expect(restored.status, Order.statusOutForDelivery);
    });
  });
}
