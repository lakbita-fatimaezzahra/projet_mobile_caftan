import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = ApiService();
  List<CategoryModel> _categories = [];
  bool _loading = true;
  String? _error;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await _api.get(
        ApiConstants.adminCategories,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _categories =
              data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement';
        _loading = false;
      });
    }
  }

  Future<void> _showCreateCategoryDialog() async {
    _nameController.clear();
    _descriptionController.clear();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom est obligatoire')),
                  );
                  return;
                }

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  final response = await _api.post(
                    ApiConstants.adminCategories,
                    headers: {
                      if (token != null) 'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'name': name,
                      'description': _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    Navigator.of(context).pop();
                    await _loadCategories();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur ${response.statusCode} lors de la création'),
                      ),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la création')),
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

  Future<void> _showEditCategoryDialog(CategoryModel category) async {
    _nameController.text = category.name;
    _descriptionController.text = category.description ?? '';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la catégorie'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnelle)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom est obligatoire')),
                  );
                  return;
                }

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('auth_token');

                  final response = await _api.post(
                    '${ApiConstants.adminCategories}/${category.id}',
                    headers: {
                      if (token != null) 'Authorization': 'Bearer $token',
                      'X-HTTP-Method-Override': 'PUT',
                    },
                    body: jsonEncode({
                      'name': name,
                      'description': _descriptionController.text.trim().isEmpty
                          ? null
                          : _descriptionController.text.trim(),
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    await _loadCategories();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur ${response.statusCode} lors de la mise à jour'),
                      ),
                    );
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la mise à jour')),
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

  Future<void> _deleteCategory(CategoryModel category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la catégorie'),
          content: Text('Voulez-vous vraiment supprimer la catégorie ${category.name} ?'),
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

    if (confirm != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _api.delete(
        '${ApiConstants.adminCategories}/${category.id}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _loadCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur ${response.statusCode} lors de la suppression de la catégorie'),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression de la catégorie')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      Center(child: Text(_error!)),
                    ],
                  )
                : ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      return ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(c.name),
                        subtitle: c.description != null
                            ? Text(c.description!)
                            : null,
                        onTap: () => _showEditCategoryDialog(c),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteCategory(c),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
