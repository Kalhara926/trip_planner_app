// lib/screens/currency_converter_screen.dart

import 'package:flutter/material.dart';
import 'package:trip_planner_app/services/currency_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController(
    text: '100.0',
  );

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String _convertedAmount = '...';
  List<String> _currencies = [];
  bool _isLoading = true;
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _loadCurrenciesAndConvert();
  }

  Future<void> _loadCurrenciesAndConvert() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supportedCurrencies = await _currencyService
          .getSupportedCurrencies();
      setState(() {
        _currencies = supportedCurrencies;
        // Ensure default currencies are in the list
        if (!_currencies.contains('USD')) _fromCurrency = _currencies.first;
        if (!_currencies.contains('EUR')) _toCurrency = _currencies.last;
      });
      _convert();
    } catch (e) {
      setState(() {
        _convertedAmount = 'Error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convert() async {
    if (_amountController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final double amount = double.parse(_amountController.text);
      final data = await _currencyService.getLatestRates(_fromCurrency);
      final rate = data['rates'][_toCurrency];
      final result = amount * rate;
      setState(() {
        _convertedAmount = result.toStringAsFixed(2);
        _lastUpdated =
            '1 $_fromCurrency = $rate $_toCurrency\nLast updated: ${data['date']}';
      });
    } catch (e) {
      setState(() {
        _convertedAmount = 'Error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: _currencies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCurrencyCard(isFrom: true),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    onPressed: _swapCurrencies,
                    mini: true,
                    child: const Icon(Icons.swap_vert),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrencyCard(isFrom: false),
                  const Spacer(),
                  Text(
                    _lastUpdated,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrencyCard({required bool isFrom}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButton<String>(
            value: isFrom ? _fromCurrency : _toCurrency,
            isExpanded: true,
            items: _currencies.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  if (isFrom) {
                    _fromCurrency = newValue;
                  } else {
                    _toCurrency = newValue;
                  }
                });
                _convert();
              }
            },
            underline: Container(), // Hides the default underline
          ),
          const SizedBox(height: 8),
          isFrom
              ? TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (value) => _convert(),
                )
              : Text(
                  _isLoading ? '...' : _convertedAmount,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ],
      ),
    );
  }
}
