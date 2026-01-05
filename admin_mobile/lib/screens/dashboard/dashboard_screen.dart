import 'package:flutter/material.dart';

import '../categories/categories_screen.dart';
import '../caftans/caftans_list_screen.dart';
import '../clients/clients_list_screen.dart';
import '../rentals/rentals_list_screen.dart';
import '../vitrine/vitrine_home_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu Admin'),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Catégories'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoriesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.checkroom),
              title: const Text('Caftans'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CaftansListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Clients'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ClientsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Locations'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RentalsListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: const Text('Vitrine Caftans'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VitrineHomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const VitrineHomeScreen(),
    );
  }
}
