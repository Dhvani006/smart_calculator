import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Currency conversion utilities with live and cached exchange rates
class CurrencyConverter {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest/INR';
  static const String _prefsKey = 'cached_exchange_rates';
  static const String _timeKey = 'last_update_time';

  // Fallback exchange rates (INR as base)
  static Map<String, dynamic> _exchangeRates = {
    'INR': 1.0,
    'USD': 0.012,
    'EUR': 0.011,
    'GBP': 0.0095,
    'AED': 0.044,
    'AUD': 0.018,
    'CAD': 0.016,
    'SGD': 0.016,
    'JPY': 1.78,
    'CNY': 0.086,
  };

  static String _lastUpdated = 'Mock Data';

  /// Fetch live rates from the API and cache them
  static Future<void> fetchLiveRates() async {
    try {
      // 1. Load from cache first
      final prefs = await SharedPreferences.getInstance();
      String? cachedData = prefs.getString(_prefsKey);
      if (cachedData != null) {
        _exchangeRates = json.decode(cachedData);
        _lastUpdated = prefs.getString(_timeKey) ?? 'Cached';
      }

      // 2. Fetch fresh data from API
      final response = await http.get(Uri.parse(_baseUrl)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _exchangeRates = data['rates'];
        
        // Format last updated time
        DateTime now = DateTime.now();
        _lastUpdated = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        // 3. Cache the new data
        await prefs.setString(_prefsKey, json.encode(_exchangeRates));
        await prefs.setString(_timeKey, _lastUpdated);
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      // If fetching fails, we still have the cached or mock data
    }
  }

  static final Map<String, String> _currencySymbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'د.إ',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'SGD': 'S\$',
    'JPY': '¥',
    'CNY': '¥',
  };

  static final Map<String, String> _currencyNames = {
    'INR': 'Indian Rupee',
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'AED': 'UAE Dirham',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'SGD': 'Singapore Dollar',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
  };

  /// Get list of available currencies
  static List<String> getCurrencies() {
    return _exchangeRates.keys.toList();
  }

  /// Get currency symbol
  static String getSymbol(String currencyCode) {
    return _currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Get currency name
  static String getName(String currencyCode) {
    return _currencyNames[currencyCode] ?? currencyCode;
  }

  /// Convert amount from one currency to another
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    
    double fromRate = (_exchangeRates[fromCurrency] as num?)?.toDouble() ?? 1.0;
    double toRate = (_exchangeRates[toCurrency] as num?)?.toDouble() ?? 1.0;
    
    // Convert to INR first, then to target currency
    double inrAmount = amount / fromRate;
    double convertedAmount = inrAmount * toRate;
    
    return convertedAmount;
  }

  /// Get exchange rate between two currencies
  static double getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return 1.0;
    
    double fromRate = (_exchangeRates[fromCurrency] as num?)?.toDouble() ?? 1.0;
    double toRate = (_exchangeRates[toCurrency] as num?)?.toDouble() ?? 1.0;
    
    return toRate / fromRate;
  }

  /// Format currency amount
  static String formatAmount(double amount, String currencyCode) {
    String symbol = getSymbol(currencyCode);
    
    // Different formatting for different currencies
    if (currencyCode == 'JPY' || currencyCode == 'CNY') {
      // No decimal places for yen/yuan
      return '$symbol${amount.toStringAsFixed(0)}';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Get last updated time
  static String getLastUpdatedTime() {
    return _lastUpdated;
  }
}
