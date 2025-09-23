// lib/services/currency_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _baseUrl = 'api.frankfurter.app';

  // ලබා දී ඇති මුදල් වර්ගයට අදාළව නවතම විනිමය අනුපාත ලබා ගැනීම
  Future<Map<String, dynamic>> getLatestRates(String fromCurrency) async {
    try {
      final uri = Uri.https(_baseUrl, '/latest', {'from': fromCurrency});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load exchange rates.');
      }
    } catch (e) {
      throw Exception('Failed to connect to the currency service.');
    }
  }

  // API එකෙන් සහාය දක්වන සියලුම මුදල් වර්ග (currencies) වල list එක ලබා ගැනීම
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final uri = Uri.https(_baseUrl, '/currencies');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Map එකේ keys (e.g., "USD", "EUR") ටික List එකක් බවට පත් කිරීම
        return data.keys.toList();
      } else {
        throw Exception('Failed to load currencies.');
      }
    } catch (e) {
      throw Exception('Failed to connect to the currency service.');
    }
  }
}
