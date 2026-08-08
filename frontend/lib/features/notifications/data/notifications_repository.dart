import '../domain/notification_item.dart';

class NotificationsRepository {
  Future<List<NotificationItem>> fetchNotifications() async {
    return [
      NotificationItem(
        id: 'nt_01',
        title: 'Evento em destaque',
        message: 'Sábado de Música ao Vivo começa em 2 horas.',
        createdAt: DateTime.now(),
      ),
      NotificationItem(
        id: 'nt_02',
        title: 'Movimentação alta',
        message: 'Bar do Bairro está com movimento intenso neste momento.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
