import '/utils/meta_info.dart';
import 'sync_service_prod.dart';

class SyncServiceDev extends SyncServiceProd {
  @override
  String get baseUrl => 'http://localhost:3000/api/client';
  @override
  String get userAgent => 'TheBeike-GUI/${MetaInfo.instance.appVersion}';
}
