import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  Future<void> _requestPermission() async {
    final settings = await NotificationService.instance.requestPermission();

    if (!mounted) return;

    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configure o Firebase para ativar notificações remotas.'),
        ),
      );
      return;
    }

    setState(() {
      notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    });
  }

  Future<void> _clearHistory() async {
    await NotificationService.instance.clearAllNotifications();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Histórico excluído.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificações'),
            subtitle: const Text('Ativar notificações do aplicativo'),
            value: notificationsEnabled,
            onChanged: (_) {
              _requestPermission();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Solicitar permissão'),
            onTap: _requestPermission,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Excluir histórico'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Excluir histórico?'),
                  content: const Text('Todas as notificações serão excluídas.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Excluir'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                _clearHistory();
              }
            },
          ),
        ],
      ),
    );
  }
}
