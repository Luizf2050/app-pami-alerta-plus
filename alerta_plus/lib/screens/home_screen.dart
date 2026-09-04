import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'device_info_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;

  @override
  void initState() {
    super.initState();

    _loadCount();
  }

  Future<void> _loadCount() async {
    final list = await NotificationService.instance.getNotifications();

    if (!mounted) return;

    setState(() {
      count = list.length;
    });
  }

  Future<void> _testNotification() async {
    await NotificationService.instance.showNotification(
      title: 'Teste de Notificação',
      message: 'Esta é uma notificação local gerada pelo aplicativo.',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'mensagem',
    );

    await _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERTA+'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCount,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.notifications_active, size: 80),
            const SizedBox(height: 20),
            const Text(
              'ALERTA+',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Sistema de notificações',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Notificações recebidas'),
                    const SizedBox(height: 10),
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _testNotification,
              icon: const Icon(Icons.notifications),
              label: const Text('Testar Notificação'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );

                _loadCount();
              },
              icon: const Icon(Icons.list),
              label: const Text('Ver Notificações'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const DeviceInfoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.phone_android),
              label: const Text('Informações do Dispositivo'),
            ),
          ],
        ),
      ),
    );
  }
}
