import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class EventsScreen extends StatelessWidget {
  final NotificationModel notification;

  const EventsScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event, size: 70),
            const SizedBox(height: 20),
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(notification.message),
          ],
        ),
      ),
    );
  }
}
