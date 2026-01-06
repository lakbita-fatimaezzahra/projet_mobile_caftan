import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/caftan.dart';
import '../../services/api_service.dart';
import '../rentals/rental_form_screen.dart';
import 'caftan_form_screen.dart';

class CaftanDetailScreen extends StatefulWidget {
  const CaftanDetailScreen({super.key, required this.caftanId});

  final int caftanId;

  @override
  State<CaftanDetailScreen> createState() => _CaftanDetailScreenState();
}

class _CaftanDetailScreenState extends State<CaftanDetailScreen> {
  final _api = ApiService();

  Caftan? _caftan;
  bool _loading = true;
  String? _error;
  int _currentImageIndex = 0;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _startDate;
  DateTime? _endDate;
  bool _checkingAvailability = false;
  bool? _isAvailableForDates;
  String? _availabilityMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  String _buildImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConstants.imagesBaseUrl}/$path';
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await _api.get(
        '${ApiConstants.adminCaftans}/${widget.caftanId}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _caftan = Caftan.fromJson(data);
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

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
        }
        _isAvailableForDates = null;
        _availabilityMessage = null;
      });
    }
  }

  Future<void> _checkAvailability() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez les dates de début et fin')),
      );
      return;
    }

    setState(() {
      _checkingAvailability = true;
      _isAvailableForDates = null;
      _availabilityMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final start = _dateFormat.format(_startDate!);
      final end = _dateFormat.format(_endDate!);

      final path = '${ApiConstants.adminRentals}'
          '?status=active'
          '&caftan_id=${widget.caftanId}'
          '&start_date=$start&end_date=$end';

      final res = await _api.get(
        path,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>;
        final hasOverlap = items.isNotEmpty;
        setState(() {
          _isAvailableForDates = !hasOverlap;
          _availabilityMessage = hasOverlap
              ? 'Ce caftan est déjà loué sur cette période.'
              : 'Ce caftan est disponible pour ces dates.';
        });
      } else {
        setState(() {
          _isAvailableForDates = null;
          _availabilityMessage = 'Erreur ${res.statusCode} lors de la vérification.';
        });
      }
    } catch (e) {
      setState(() {
        _isAvailableForDates = null;
        _availabilityMessage = 'Erreur lors de la vérification.';
      });
    } finally {
      setState(() {
        _checkingAvailability = false;
      });
    }
  }

  Future<void> _openEdit() async {
    if (_caftan == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CaftanFormScreen(caftan: _caftan),
      ),
    );

    if (updated == true) {
      _loadDetail();
    }
  }

  Future<void> _deleteCaftan() async {
    if (_caftan == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le caftan'),
          content: const Text(
              'Voulez-vous vraiment supprimer ce caftan ? Cette action est définitive.'),
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

      final res = await _api.delete(
        '${ApiConstants.adminCaftans}/${_caftan!.id}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erreur ${res.statusCode} lors de la suppression du caftan'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression du caftan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail caftan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _caftan == null ? null : _openEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _caftan == null ? null : _deleteCaftan,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _caftan == null
                  ? const Center(child: Text('Caftan introuvable'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          if (_caftan!.images.isNotEmpty) ...[
                            SizedBox(
                              height: 260,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: _caftan!.images.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentImageIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final img = _caftan!.images[index];
                                        return CachedNetworkImage(
                                          imageUrl: _buildImageUrl(img.imagePath),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.broken_image),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          _caftan!.images.length,
                                          (index) => Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 3),
                                            width: _currentImageIndex == index ? 10 : 6,
                                            height: _currentImageIndex == index ? 10 : 6,
                                            decoration: BoxDecoration(
                                              color: _currentImageIndex == index
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.6),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            _caftan!.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                _caftan!.categoryName ?? 'Sans catégorie',
                                style:
                                    const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 12),
                              Builder(
                                builder: (context) {
                                  // Si une période a été vérifiée, on priorise ce résultat
                                  final bool? byDates = _isAvailableForDates;

                                  String label;
                                  Color color;

                                  if (byDates != null) {
                                    if (byDates) {
                                      label = 'Disponible sur cette période';
                                      color = Colors.greenAccent;
                                    } else {
                                      label = 'Loué sur cette période';
                                      color = Colors.redAccent;
                                    }
                                  } else {
                                    // Sinon on affiche le statut global du caftan
                                    label = _caftan!.isAvailable
                                        ? 'Disponible'
                                        : 'Loué';
                                    color = _caftan!.isAvailable
                                        ? Colors.greenAccent
                                        : Colors.redAccent;
                                  }

                                  return Chip(
                                    label: Text(label),
                                    backgroundColor: color,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_caftan!.pricePerDay.toStringAsFixed(2)} MAD / jour',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(_caftan!.description),
                          const SizedBox(height: 24),
                          Text(
                            'Vérifier la disponibilité',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickDate(isStart: true),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date début',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _startDate == null
                                          ? 'Choisir'
                                          : _dateFormat.format(_startDate!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickDate(isStart: false),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date fin',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(
                                      _endDate == null
                                          ? 'Choisir'
                                          : _dateFormat.format(_endDate!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _checkingAvailability ? null : _checkAvailability,
                            child: _checkingAvailability
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Vérifier la disponibilité'),
                          ),
                          if (_availabilityMessage != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _availabilityMessage!,
                              style: TextStyle(
                                color: _isAvailableForDates == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _isAvailableForDates == true
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => RentalFormScreen(
                                          initialCaftan: _caftan,
                                          initialStartDate: _startDate,
                                          initialEndDate: _endDate,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.event_available),
                            label: const Text('Ajouter location'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
