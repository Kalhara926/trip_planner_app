// File: lib/screens/tip_calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // මුදල් format කිරීමට

class TipCalculatorScreen extends StatefulWidget {
  const TipCalculatorScreen({super.key});

  @override
  State<TipCalculatorScreen> createState() => _TipCalculatorScreenState();
}

class _TipCalculatorScreenState extends State<TipCalculatorScreen> {
  final _billController = TextEditingController();
  final _tipPercentageController = TextEditingController();
  final _peopleController = TextEditingController(text: '1');

  double _tipAmount = 0.0;
  double _totalAmount = 0.0;
  double _amountPerPerson = 0.0;

  @override
  void initState() {
    super.initState();
    // Controllers වලට listeners එකතු කිරීම. User type කරන ගමන් calculate වෙන්න.
    _billController.addListener(_calculateTip);
    _tipPercentageController.addListener(_calculateTip);
    _peopleController.addListener(_calculateTip);
  }

  @override
  void dispose() {
    // Controllers dispose කිරීම
    _billController.dispose();
    _tipPercentageController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  void _calculateTip() {
    final double billAmount = double.tryParse(_billController.text) ?? 0.0;
    final double tipPercentage =
        double.tryParse(_tipPercentageController.text) ?? 0.0;
    final int numberOfPeople = int.tryParse(_peopleController.text) ?? 1;

    if (billAmount > 0 && numberOfPeople > 0) {
      setState(() {
        _tipAmount = billAmount * (tipPercentage / 100);
        _totalAmount = billAmount + _tipAmount;
        _amountPerPerson = _totalAmount / numberOfPeople;
      });
    } else {
      // Input එක valid නැත්නම්, ඔක්කොම 0.0 කරනවා
      setState(() {
        _tipAmount = 0.0;
        _totalAmount = 0.0;
        _amountPerPerson = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tip Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputField(
              controller: _billController,
              label: 'Total Bill Amount',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _tipPercentageController,
              label: '% Tip Percentage',
              icon: Icons.percent,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _peopleController,
              label: 'Number of People',
              icon: Icons.people,
            ),
            const SizedBox(height: 32),
            _buildResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Results',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _buildResultRow('Tip Amount:', currencyFormat.format(_tipAmount)),
          const SizedBox(height: 12),
          _buildResultRow('Total Amount:', currencyFormat.format(_totalAmount)),
          const SizedBox(height: 12),
          _buildResultRow(
            'Amount Per Person:',
            currencyFormat.format(_amountPerPerson),
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String title,
    String amount, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isHighlighted
                ? Theme.of(context).primaryColor
                : Colors.black87,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            color: isHighlighted
                ? Theme.of(context).primaryColor
                : Colors.black,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
