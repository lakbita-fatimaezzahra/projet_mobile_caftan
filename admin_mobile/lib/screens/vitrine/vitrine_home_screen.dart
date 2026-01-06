import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/caftan.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';
import '../caftans/caftan_detail_screen.dart';

class VitrineHomeScreen extends StatefulWidget {
  const VitrineHomeScreen({super.key});

  @override
  State<VitrineHomeScreen> createState() => _VitrineHomeScreenState();
}

class _VitrineHomeScreenState extends State<VitrineHomeScreen> {
  final _api = ApiService();

  bool _loading = true;
  String? _error;

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;

  List<Caftan> _caftans = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await Future.wait([
        _loadCategoriesInternal(),
        _loadCaftansInternal(),
      ]);

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement';
        _loading = false;
      });
    }
  }

  Future<void> _loadCategoriesInternal() async {
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
      _categories =
          data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erreur categories');
    }
  }

  Future<void> _loadCaftansInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final queryParams = <String, String>{
      // On ne filtre plus par disponibilité pour afficher tous les caftans
      'limit': '10',
    };

    if (_selectedCategoryId != null) {
      queryParams['category_id'] = _selectedCategoryId.toString();
    }

    final path = ApiConstants.adminCaftans +
        (queryParams.isEmpty
            ? ''
            : '?' +
                queryParams.entries
                    .map((e) =>
                        '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
                    .join('&'));

    final response = await _api.get(
      path,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>;
      final allCaftans =
          items.map((e) => Caftan.fromJson(e as Map<String, dynamic>)).toList();
      // On garde seulement les 10 premiers côté front si le backend ne gère pas limit
      _caftans = allCaftans.take(10).toList();
    } else {
      throw Exception('Erreur caftans');
    }
  }

  Future<void> _reloadCaftans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _loadCaftansInternal();
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement';
        _loading = false;
      });
    }
  }

  String _buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConstants.imagesBaseUrl}/$path';
  }

  List<String> _extractImages(Caftan c) {
    if (c.images.isNotEmpty) {
      return c.images.map((img) => img.imagePath).toList();
    }
    if (c.imageUrl != null) {
      return [c.imageUrl!];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitrine Caftans'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 100),
                      Center(child: Text(_error!)),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Hero image / bandeau
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            'assets/images/caftan.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Text('Vitrine Caftans'),
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 16),
                      // Sélecteur de catégorie
                      DropdownButtonFormField<int?>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Toutes les catégories'),
                          ),
                          ..._categories.map(
                            (c) => DropdownMenuItem<int?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedCategoryId = val;
                          });
                          _reloadCaftans();
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_caftans.isEmpty)
                        const Center(
                          child: Text('Aucun caftan trouvé pour cette sélection.'),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sélection de caftans',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ..._caftans.map((c) {
                              final images = _extractImages(c);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CaftanDetailScreen(
                                          caftanId: c.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 220,
                                          child: images.isEmpty
                                              ? Container(
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: const Icon(Icons.checkroom,
                                                      size: 48),
                                                )
                                              : PageView.builder(
                                                  itemCount: images.length,
                                                  itemBuilder: (context, index) {
                                                    final url =
                                                        _buildImageUrl(images[index]);
                                                    return CachedNetworkImage(
                                                      imageUrl: url,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                      errorWidget:
                                                          (context, url, error) =>
                                                              const Icon(
                                                        Icons.broken_image,
                                                      ),
                                                    );
                                                  },
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                c.categoryName ?? 'Sans catégorie',
                                                style: TextStyle(
                                                  color:
                                                      Colors.grey.shade700,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${c.pricePerDay.toStringAsFixed(2)} MAD / jour',
                                                style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
      ),
    );
  }
}
