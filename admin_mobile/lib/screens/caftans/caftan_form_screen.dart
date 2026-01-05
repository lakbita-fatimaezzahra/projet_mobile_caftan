import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/caftan.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class CaftanFormScreen extends StatefulWidget {
  const CaftanFormScreen({super.key, this.caftan});

  final Caftan? caftan;

  @override
  State<CaftanFormScreen> createState() => _CaftanFormScreenState();
}

class _CaftanFormScreenState extends State<CaftanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _api = ApiService();

  bool _isAvailable = true;
  bool _loading = false;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  final List<XFile> _newImages = [];

  @override
  void initState() {
    super.initState();
    if (widget.caftan != null) {
      _nameController.text = widget.caftan!.name;
      _descriptionController.text = widget.caftan!.description;
      _priceController.text = widget.caftan!.pricePerDay.toStringAsFixed(2);
      _isAvailable = widget.caftan!.isAvailable;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
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
        final cats =
            data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
        setState(() {
          _categories = cats;
          if (widget.caftan != null && widget.caftan!.categoryName != null) {
            _selectedCategory = _categories
                .firstWhere((c) => c.name == widget.caftan!.categoryName, orElse: () => cats.first);
          }
        });
      }
    } catch (_) {
      // ignore for now
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price_per_day': double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      'category_id': _selectedCategory!.id,
      'is_available': _isAvailable,
    };

    final isEdit = widget.caftan != null;
    final path = isEdit
        ? '${ApiConstants.adminCaftans}/${widget.caftan!.id}'
        : ApiConstants.adminCaftans;

    final response = await (isEdit
        ? _api.post(
            path,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'X-HTTP-Method-Override': 'PUT',
            },
            body: jsonEncode(payload),
          )
        : _api.post(
            path,
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final id = data['id'] as int? ?? widget.caftan?.id;

      if (id != null && _newImages.isNotEmpty) {
        await _uploadImages(id, token);
      }

      setState(() {
        _loading = false;
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ${response.statusCode}')),
      );
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImages
          ..clear()
          ..addAll(images);
      });
    }
  }

  Future<void> _uploadImages(int caftanId, String? token) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.adminCaftans}/$caftanId/images',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json';

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    for (final img in _newImages) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', img.path),
      );
    }

    await request.send();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.caftan != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier un caftan' : 'Nouveau caftan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nom obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true, signed: false),
                decoration: const InputDecoration(
                  labelText: 'Prix par jour (MAD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prix obligatoire';
                  }
                  final parsed =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed < 0) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CategoryModel>(
                value: _selectedCategory,
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image),
                    label: const Text('Ajouter des images'),
                  ),
                  const SizedBox(width: 12),
                  if (_newImages.isNotEmpty)
                    Text('${_newImages.length} image(s) sélectionnée(s)'),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isAvailable,
                title: const Text('Disponible'),
                onChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Mettre à jour' : 'Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
