import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({
    super.key,
  });

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final service = NotificationService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Dispositivo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.phone_android, size: 80),
          const SizedBox(height: 30),
          const Text(
            'Token FCM',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SelectableText(service.fcmToken ?? 'Token não disponível'),
          const SizedBox(height: 30),
          const Text(
            'Plataforma',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(Platform.operatingSystem),
          const SizedBox(height: 30),
          const Text(
            'Status do Firebase',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            Firebase.apps.isNotEmpty
                ? 'Firebase conectado com sucesso!'
                : 'Firebase não conectado.',
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              await service.getFCMToken();

              setState(() {});
            },
            child: const Text('Atualizar Token FCM'),
          ),
        ],
      ),
    );
  }
}
