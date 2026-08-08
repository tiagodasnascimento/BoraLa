import 'package:flutter_test/flutter_test.dart';
import 'package:bora_la/features/notifications/data/notifications_repository.dart';

void main() {
  test('fetchNotifications returns items', () async {
    final repository = NotificationsRepository();

    final notifications = await repository.fetchNotifications();

    expect(notifications, isNotEmpty);
    expect(notifications.first.title, 'Evento em destaque');
  });
}
