import 'sync_service_prod.dart';

class SyncServiceDev extends SyncServiceProd {
  @override
  String get baseUrl => 'http://127.0.0.1:3000/api/client';
  @override
  String get userAgent => 'TheBeike-GUI/dev';
}
