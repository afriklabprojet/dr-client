import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrdersRemoteDataSource {
  final ApiClient apiClient;

  OrdersRemoteDataSource(this.apiClient);

  /// Get all orders for the current user
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};

    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await apiClient.get(
      '/customer/orders',
      queryParameters: queryParams,
    );

    final List<dynamic> ordersJson = response.data['data'] as List<dynamic>;
    return ordersJson
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get order details by ID
  Future<OrderModel> getOrderDetails(int orderId) async {
    final response = await apiClient.get('/customer/orders/$orderId');
    return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Create a new order
  Future<OrderModel> createOrder({
    required int pharmacyId,
    required List<OrderItemModel> items,
    required Map<String, dynamic> deliveryAddress,
    required String paymentMode,
    String? prescriptionImage,
    String? customerNotes,
  }) async {
    final data = {
      'pharmacy_id': pharmacyId,
      'items': items.map((item) => item.toJson()).toList(),
      'delivery_address': deliveryAddress['address'],
      if (deliveryAddress['city'] != null)
        'delivery_city': deliveryAddress['city'],
      if (deliveryAddress['latitude'] != null)
        'delivery_latitude': deliveryAddress['latitude'],
      if (deliveryAddress['longitude'] != null)
        'delivery_longitude': deliveryAddress['longitude'],
      if (deliveryAddress['phone'] != null)
        'customer_phone': deliveryAddress['phone'],
      'payment_mode': paymentMode,
      if (prescriptionImage != null) 'prescription_image': prescriptionImage,
      if (customerNotes != null) 'customer_notes': customerNotes,
    };

    final response = await apiClient.post('/customer/orders', data: data);

    // API returns simplified response on creation
    final responseData = response.data['data'] as Map<String, dynamic>;

    // Fetch full order details
    return await getOrderDetails(responseData['order_id'] as int);
  }

  /// Cancel an order
  Future<void> cancelOrder(int orderId, String reason) async {
    await apiClient.post(
      '/customer/orders/$orderId/cancel',
      data: {'reason': reason},
    );
  }

  /// Initiate payment for an order
  Future<Map<String, dynamic>> initiatePayment({
    required int orderId,
    required String provider,
  }) async {
    final response = await apiClient.post(
      '/customer/orders/$orderId/payment/initiate',
      data: {'provider': provider},
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get tracking info manually (returns raw json for delivery part)
  Future<Map<String, dynamic>?> getTrackingInfo(int orderId) async {
    final response = await apiClient.get('/customer/orders/$orderId');
    final data = response.data['data'] as Map<String, dynamic>;
    if (data['delivery'] != null) {
      return data['delivery'] as Map<String, dynamic>;
    }
    return null;
  }
}
