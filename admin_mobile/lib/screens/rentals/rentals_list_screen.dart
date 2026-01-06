import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/rental.dart';
import '../../services/api_service.dart';
import 'rental_form_screen.dart';

class RentalsListScreen extends StatefulWidget {
  const RentalsListScreen({super.key});

  @override
  State<RentalsListScreen> createState() => _RentalsListScreenState();
}

class _RentalsListScreenState extends State<RentalsListScreen> {
  final _api = ApiService();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  List<RentalModel> _rentals = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'all';
  String _paymentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final params = <String, String>{};
      if (_statusFilter != 'all') params['status'] = _statusFilter;
      if (_paymentFilter != 'all') params['payment_status'] = _paymentFilter;

      final path = ApiConstants.adminRentals +
          (params.isEmpty
              ? ''
              : '?' +
                  params.entries
                      .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
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
        setState(() {
          _rentals =
              items.map((e) => RentalModel.fromJson(e as Map<String, dynamic>)).toList();
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

  Future<void> _deleteRental(RentalModel rental) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la location'),
          content: Text(
              'Voulez-vous vraiment supprimer la location de ${rental.clientName} pour ${rental.caftanName} ?'),
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
        '${ApiConstants.adminRentals}/${rental.id}',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        await _loadRentals();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur ${response.statusCode} lors de la suppression de la location'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression de la location')),
      );
    }
  }

  Future<void> _showRentalDetail(RentalModel rental) async {
    String status = rental.status;
    String paymentStatus = rental.paymentStatus;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Détail de la location'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Client : ${rental.clientName}'),
                    Text('Caftan : ${rental.caftanName}'),
                    Text('Taille : ${rental.sizeName}'),
                    const SizedBox(height: 8),
                    Text(
                        'Période : ${_dateFormat.format(rental.startDate)} → ${_dateFormat.format(rental.endDate)}'),
                    Text('Jours : ${rental.totalDays}'),
                    const SizedBox(height: 8),
                    Text(
                        'Total : ${rental.totalPrice.toStringAsFixed(2)} MAD'),
                    Text(
                        'Caution : ${rental.depositAmount.toStringAsFixed(2)} MAD'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: 'returned',
                          child: Text('Retournée'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Annulée'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setStateDialog(() {
                          status = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      decoration: const InputDecoration(
                        labelText: 'Statut de paiement',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('En attente'),
                        ),
                        DropdownMenuItem(
                          value: 'partial',
                          child: Text('Partiel'),
                        ),
                        DropdownMenuItem(
                          value: 'paid',
                          child: Text('Payé'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setStateDialog(() {
                          paymentStatus = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _deleteRental(rental);
                  },
                  child: const Text(
                    'Supprimer',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final token = prefs.getString('auth_token');

                      // Mettre à jour le statut
                      await _api.post(
                        '${ApiConstants.adminRentals}/${rental.id}/status',
                        headers: {
                          if (token != null)
                            'Authorization': 'Bearer $token',
                          'X-HTTP-Method-Override': 'PUT',
                        },
                        body: jsonEncode({'status': status}),
                      );

                      // Mettre à jour le statut de paiement
                      await _api.post(
                        '${ApiConstants.adminRentals}/${rental.id}/payment',
                        headers: {
                          if (token != null)
                            'Authorization': 'Bearer $token',
                          'X-HTTP-Method-Override': 'PUT',
                        },
                        body: jsonEncode({'payment_status': paymentStatus}),
                      );

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      await _loadRentals();
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Erreur lors de la mise à jour de la location')),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'active', child: Text('Actives')),
                      DropdownMenuItem(value: 'returned', child: Text('Retournées')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Annulées')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _statusFilter = val);
                      _loadRentals();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _paymentFilter,
                    decoration: const InputDecoration(
                      labelText: 'Paiement',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tous')),
                      DropdownMenuItem(value: 'pending', child: Text('En attente')),
                      DropdownMenuItem(value: 'partial', child: Text('Partiel')),
                      DropdownMenuItem(value: 'paid', child: Text('Payé')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _paymentFilter = val);
                      _loadRentals();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadRentals,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? ListView(children: [Center(child: Text(_error!))])
                      : ListView.builder(
                          itemCount: _rentals.length,
                          itemBuilder: (context, index) {
                            final r = _rentals[index];
                            return ListTile(
                              leading: const Icon(Icons.event),
                              title: Text('${r.clientName} - ${r.caftanName}'),
                              subtitle: Text(
                                '${_dateFormat.format(r.startDate)} → ${_dateFormat.format(r.endDate)} • ${r.totalPrice.toStringAsFixed(2)} MAD',
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(r.status),
                                  Text(
                                    r.paymentStatus,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              onTap: () => _showRentalDetail(r),
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
              builder: (_) => const RentalFormScreen(),
            ),
          );
          if (created == true) {
            _loadRentals();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
