import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/caftan.dart';
import '../../services/api_service.dart';
import 'caftan_detail_screen.dart';
import 'caftan_form_screen.dart';

class CaftansListScreen extends StatefulWidget {
  const CaftansListScreen({super.key});

  @override
  State<CaftansListScreen> createState() => _CaftansListScreenState();
}

class _CaftansListScreenState extends State<CaftansListScreen> {
  final _api = ApiService();
  final _searchController = TextEditingController();

  List<Caftan> _caftans = [];
  bool _loading = true;
  String? _error;
  String _availabilityFilter = 'all'; // all / available / rented

  @override
  void initState() {
    super.initState();
    _loadCaftans();
  }

  Future<void> _loadCaftans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final queryParams = <String, String>{};
      if (_searchController.text.isNotEmpty) {
        queryParams['search'] = _searchController.text.trim();
      }
      if (_availabilityFilter == 'available') {
        queryParams['availability'] = 'available';
      } else if (_availabilityFilter == 'rented') {
        queryParams['availability'] = 'rented';
      }

      final path = ApiConstants.adminCaftans +
          (queryParams.isEmpty
              ? ''
              : '?' +
                  queryParams.entries
                      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
                      .join('&'));

      final response = await _api.get(
        path,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // DEBUG: inspect response from /api/admin/caftans
      debugPrint('GET caftans => status: ${response.statusCode}');
      debugPrint('GET caftans => body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>;
        setState(() {
          _caftans =
              items.map((e) => Caftan.fromJson(e as Map<String, dynamic>)).toList();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      // DEBUG: log any exception during loading/parsing
      debugPrint('Error loading caftans: $e');
      setState(() {
        _error = 'Erreur de chargement';
        _loading = false;
      });
    }
  }

  void _onSearch() {
    _loadCaftans();
  }

  void _onChangeAvailability(String? value) {
    if (value == null) return;
    setState(() {
      _availabilityFilter = value;
    });
    _loadCaftans();
  }

  Future<void> _deleteCaftan(Caftan caftan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le caftan'),
          content: Text('Voulez-vous vraiment supprimer ${caftan.name} ?'),
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
        '${ApiConstants.adminCaftans}/${caftan.id}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await _loadCaftans();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur ${response.statusCode} lors de la suppression du caftan'),
          ),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du caftan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caftans'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Rechercher un caftan...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _availabilityFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('Tous'),
                    ),
                    DropdownMenuItem(
                      value: 'available',
                      child: Text('Disponibles'),
                    ),
                    DropdownMenuItem(
                      value: 'rented',
                      child: Text('En location'),
                    ),
                  ],
                  onChanged: _onChangeAvailability,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCaftans,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(
                          children: [
                            Center(child: Text(_error!)),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _caftans.length,
                          itemBuilder: (context, index) {
                            final c = _caftans[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(c.name.isNotEmpty ? c.name[0] : '?'),
                              ),
                              title: Text(c.name),
                              subtitle: Text(
                                '${c.categoryName ?? 'Sans catégorie'} • ${c.pricePerDay.toStringAsFixed(2)} MAD/jour',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  c.isAvailable
                                      ? const Chip(
                                          label: Text('Disponible'),
                                          backgroundColor: Colors.greenAccent,
                                        )
                                      : const Chip(
                                          label: Text('Loué'),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => _deleteCaftan(c),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CaftanDetailScreen(caftanId: c.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const CaftanFormScreen(),
            ),
          );
          if (created == true) {
            _loadCaftans();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
