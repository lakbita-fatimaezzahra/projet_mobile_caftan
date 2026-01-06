import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../models/caftan.dart';
import '../../models/client.dart';
import '../../services/api_service.dart';

class RentalFormScreen extends StatefulWidget {
  const RentalFormScreen({super.key, this.initialCaftan, this.initialStartDate, this.initialEndDate});

  final Caftan? initialCaftan;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  // Reservation mode: existing client vs new client
  // false = existing client (default), true = create new client
  bool _isNewClient = false;

  // Fields for new client
  final _existingClientCinController = TextEditingController();
  final _newClientCinController = TextEditingController();
  final _newClientNameController = TextEditingController();
  final _newClientPhoneController = TextEditingController();
  final _newClientEmailController = TextEditingController();
  final _newClientAddressController = TextEditingController();

  ClientModel? _selectedClient;
  Caftan? _selectedCaftan;
  DateTime? _startDate;
  DateTime? _endDate;
  double _totalPrice = 0;
  double _deposit = 0;
  String _paymentStatus = 'pending';

  bool _loading = false;
  List<ClientModel> _clients = [];
  List<Caftan> _caftans = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Future<List<ClientModel>> loadClients() async {
      final res = await _api.get(
        ApiConstants.adminClients,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>;
        return items
            .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    Future<List<Caftan>> loadCaftans() async {
      final res = await _api.get(
        ApiConstants.adminCaftans,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = data['data'] as List<dynamic>;
        return items
            .map((e) => Caftan.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    final results = await Future.wait([
      loadClients(),
      loadCaftans(),
    ]);

    setState(() {
      _clients = results[0] as List<ClientModel>;
      _caftans = results[1] as List<Caftan>;
      // Pré-sélectionner le caftan et les dates si fournis
      if (widget.initialCaftan != null) {
        try {
          _selectedCaftan =
              _caftans.firstWhere((c) => c.id == widget.initialCaftan!.id);
        } catch (_) {
          _selectedCaftan = widget.initialCaftan;
        }
      }
      if (widget.initialStartDate != null) {
        _startDate = widget.initialStartDate;
      }
      if (widget.initialEndDate != null) {
        _endDate = widget.initialEndDate;
      }
    });

    // Mettre à jour le prix si tout est prêt
    _updateTotalPrice();
  }

  void _updateTotalPrice() {
    if (_startDate == null || _endDate == null || _selectedCaftan == null) {
      setState(() => _totalPrice = 0);
      return;
    }

    final days = _endDate!.difference(_startDate!).inDays + 1;
    setState(() {
      _totalPrice = days * _selectedCaftan!.pricePerDay;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
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
      });
      _updateTotalPrice();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez les dates de début et fin')),
      );
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    int? clientId = _selectedClient?.id;

    // If creating a new client, create it first and reuse its id
    if (_isNewClient) {
      final cin = _newClientCinController.text.trim();
      final name = _newClientNameController.text.trim();
      final phone = _newClientPhoneController.text.trim();
      final email = _newClientEmailController.text.trim();
      final address = _newClientAddressController.text.trim();

      final clientRes = await _api.post(
        ApiConstants.adminClients,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'cin': cin.isEmpty ? null : cin,
          'phone': phone,
          'email': email.isEmpty ? null : email,
          'address': address.isEmpty ? null : address,
        }),
      );

      if (clientRes.statusCode != 201 && clientRes.statusCode != 200) {
        setState(() => _loading = false);
        String message = 'Erreur ${clientRes.statusCode} lors de la création du client';
        try {
          final body = jsonDecode(clientRes.body);
          message = body.toString();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }

      final clientData = jsonDecode(clientRes.body) as Map<String, dynamic>;
      clientId = clientData['id'] as int?;

      if (clientId == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client créé sans identifiant valide')),
        );
        return;
      }
    }

    final totalDays = _endDate!.difference(_startDate!).inDays + 1;

    final payload = {
      'client_id': clientId,
      'caftan_id': _selectedCaftan!.id,
      'start_date': _dateFormat.format(_startDate!),
      'end_date': _dateFormat.format(_endDate!),
      'total_days': totalDays,
      'total_price': _totalPrice,
      'deposit_amount': _deposit,
      'status': 'active',
      'payment_status': _paymentStatus,
      'notes': null,
    };

    final res = await _api.post(
      ApiConstants.adminRentals,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    setState(() => _loading = false);

    if (res.statusCode == 201 || res.statusCode == 200) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur ${res.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isNewClient ? Colors.grey.shade300 : Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewClient = false;
                        });
                      },
                      child: Text(
                        'Chercher client',
                        style: TextStyle(
                          color: _isNewClient ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isNewClient ? Colors.orange : Colors.grey.shade300,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewClient = true;
                        });
                      },
                      child: Text(
                        'Nouveau client',
                        style: TextStyle(
                          color: _isNewClient ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isNewClient) ...[
                TextFormField(
                  controller: _existingClientCinController,
                  decoration: const InputDecoration(
                    labelText: 'CIN du client',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (_isNewClient) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Entrez le CIN du client';
                    }
                    if (_selectedClient == null) {
                      return 'Recherchez le client par CIN';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final cin = _existingClientCinController.text.trim();
                    if (cin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un CIN pour rechercher')),
                      );
                      return;
                    }

                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');

                    final res = await _api.get(
                      ApiConstants.adminClients +
                          '?cin=' + Uri.encodeQueryComponent(cin),
                      headers: {
                        if (token != null) 'Authorization': 'Bearer $token',
                      },
                    );

                    if (res.statusCode == 200) {
                      final data = jsonDecode(res.body) as Map<String, dynamic>;
                      final items = data['data'] as List<dynamic>;
                      if (items.isNotEmpty) {
                        setState(() {
                          _selectedClient =
                              ClientModel.fromJson(items.first as Map<String, dynamic>);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Client trouvé: '
                                  '${_selectedClient!.name} (${_selectedClient!.phone})')),
                        );
                      } else {
                        setState(() {
                          _selectedClient = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Aucun client trouvé avec ce CIN')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Erreur ${res.statusCode} lors de la recherche du client')),
                      );
                    }
                  },
                  child: const Text('Rechercher le client'),
                ),
                const SizedBox(height: 8),
                if (_selectedClient != null)
                  Text(
                    'Client sélectionné: ${_selectedClient!.name} (${_selectedClient!.phone})',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 16),
              ] else ...[
                TextFormField(
                  controller: _newClientCinController,
                  decoration: const InputDecoration(
                    labelText: 'CIN',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (!_isNewClient) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Entrez le CIN du client';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newClientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet du client',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (!_isNewClient) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Entrez le nom du client';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newClientPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone du client',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (!_isNewClient) return null;
                    if (v == null || v.trim().isEmpty) {
                      return 'Entrez le téléphone du client';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newClientEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newClientAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              DropdownButtonFormField<Caftan>(
                value: _selectedCaftan,
                items: _caftans
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedCaftan = v);
                  _updateTotalPrice();
                },
                decoration: const InputDecoration(
                  labelText: 'Caftan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Choisissez un caftan' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: Text(
                        _startDate == null
                            ? 'Date début'
                            : _dateFormat.format(_startDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: Text(
                        _endDate == null
                            ? 'Date fin'
                            : _dateFormat.format(_endDate!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Total: ${_totalPrice.toStringAsFixed(2)} MAD'),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Caution (MAD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                onChanged: (v) {
                  final value = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                  setState(() => _deposit = value);
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _paymentStatus,
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('En attente')),
                  DropdownMenuItem(value: 'partial', child: Text('Partiel')),
                  DropdownMenuItem(value: 'paid', child: Text('Payé')),
                ],
                onChanged: (v) => setState(() => _paymentStatus = v ?? 'pending'),
                decoration: const InputDecoration(
                  labelText: 'Statut de paiement',
                  border: OutlineInputBorder(),
                ),
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
                      : const Text('Créer la location'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
