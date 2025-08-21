import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuraciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text('Tema'),
            subtitle: Text('Claro'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notificaciones'),
            subtitle: Text('Activadas'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Acerca de'),
            subtitle: Text('SimpleTask v1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('Desarrollado por'),
            subtitle: Text('Tu nombre aquí'),
          ),
        ],
      ),
    );
  }
}