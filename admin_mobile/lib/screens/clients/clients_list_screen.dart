import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/client.dart';
import '../../services/api_service.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final _api = ApiService();
  List<ClientModel> _clients = [];
  bool _loading = true;
  String? _error;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cinController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _api.get(
        ApiConstants.adminClients,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>;
        setState(() {
          _clients =
              items.map((e) => ClientModel.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Erreur de chargement';
        _loading = false;
      });
    }
  }

  Future<void> _showCreateClientDialog() async {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _cinController.clear();
    _addressController.clear();
    _notesController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cinController,
                  decoration: const InputDecoration(labelText: 'CIN (optionnel)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email (optionnel)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adresse (optionnelle)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optionnelles)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom et téléphone sont obligatoires')),
                  );
                  return;
                }

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  final response = await _api.post(
                    ApiConstants.adminClients,
                    headers: {
                      if (token != null) 'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'name': name,
                      'phone': phone,
                      'cin': _cinController.text.trim().isEmpty
                          ? null
                          : _cinController.text.trim(),
                      'email': _emailController.text.trim().isEmpty
                          ? null
                          : _emailController.text.trim(),
                      'address': _addressController.text.trim().isEmpty
                          ? null
                          : _addressController.text.trim(),
                      'notes': _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.of(context).pop();
                    await _loadClients();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Erreur ${response.statusCode} lors de la création du client'),
                      ),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la création du client')),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteClient(ClientModel client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le client'),
          content: Text('Voulez-vous vraiment supprimer ${client.name} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _api.delete(
        '${ApiConstants.adminClients}/${client.id}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _loadClients();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erreur ${response.statusCode} lors de la suppression du client'),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du client')),
      );
    }
  }

  Future<void> _showEditClientDialog(ClientModel client) async {
    _nameController.text = client.name;
    _phoneController.text = client.phone;
    _emailController.text = client.email ?? '';
    _cinController.text = client.cin ?? '';
    _addressController.clear();
    _notesController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cinController,
                  decoration: const InputDecoration(labelText: 'CIN (optionnel)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email (optionnel)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adresse (optionnelle)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optionnelles)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();

                if (name.isEmpty || phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nom et téléphone sont obligatoires')),
                  );
                  return;
                }

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  final response = await _api.post(
                    '${ApiConstants.adminClients}/${client.id}',
                    headers: {
                      if (token != null) 'Authorization': 'Bearer $token',
                      'X-HTTP-Method-Override': 'PUT',
                    },
                    body: jsonEncode({
                      'name': name,
                      'phone': phone,
                      'cin': _cinController.text.trim().isEmpty
                          ? null
                          : _cinController.text.trim(),
                      'email': _emailController.text.trim().isEmpty
                          ? null
                          : _emailController.text.trim(),
                      'address': _addressController.text.trim().isEmpty
                          ? null
                          : _addressController.text.trim(),
                      'notes': _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    await _loadClients();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Erreur ${response.statusCode} lors de la mise à jour du client'),
                      ),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la mise à jour du client')),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadClients,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Center(child: Text(_error!)),
                    ],
                  )
                : ListView.builder(
                    itemCount: _clients.length,
                    itemBuilder: (context, index) {
                      final c = _clients[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(c.name),
                        subtitle: Text(c.email != null && c.email!.isNotEmpty
                            ? '${c.phone} • ${c.email}'
                            : c.phone),
                        onTap: () => _showEditClientDialog(c),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteClient(c),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateClientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
