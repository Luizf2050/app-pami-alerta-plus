import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import 'events_screen.dart';
import 'messages_screen.dart';
import 'task_detail_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  void _openSpecificScreen(BuildContext context) {
    switch (notification.type.toLowerCase()) {
      case 'tarefa':
      case 'task':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => TaskDetailScreen(notification: notification),
          ),
        );
        break;

      case 'evento':
      case 'event':
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => EventsScreen(notification: notification),
          ),
        );
        break;

      case 'mensagem':
      case 'message':
      default:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => MessagesScreen(notification: notification),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              notification.message,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text('Tipo: ${notification.type}'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _openSpecificScreen(context);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir conteúdo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
