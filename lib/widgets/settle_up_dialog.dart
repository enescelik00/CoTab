import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/money.dart';

// The dialog that opens when "Paid" is tapped. It shows who pays whom and
// an amount field that already has the suggested amount in it. The user
// can lower it for a part payment, but not raise it above the suggestion.
//
// Open it with showDialog<int>. It closes with the paid amount in kuruş,
// or with null when the user cancels.
class SettleUpDialog extends StatefulWidget {
  final String fromName;
  final String toName;
  final int suggestedAmount; // in kuruş

  const SettleUpDialog({
    super.key,
    required this.fromName,
    required this.toName,
    required this.suggestedAmount,
  });

  @override
  State<SettleUpDialog> createState() => _SettleUpDialogState();
}

class _SettleUpDialogState extends State<SettleUpDialog> {
  late final TextEditingController _amountController;
  // Shown under the field when the amount is wrong; null when it is fine.
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: formatMoneyForInput(widget.suggestedAmount),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final texts = AppLocalizations.of(context)!;
    final amount = parseMoney(_amountController.text);

    if (amount == null || amount <= 0) {
      setState(() {
        _errorText = texts.amountInvalid;
      });
      return;
    }
    if (amount > widget.suggestedAmount) {
      setState(() {
        _errorText = texts.paymentTooHigh(formatMoney(widget.suggestedAmount));
      });
      return;
    }

    Navigator.pop(context, amount);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(texts.recordPaymentTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.fromName} → ${widget.toName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: texts.amountLabel,
              errorText: _errorText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(texts.cancelButton),
        ),
        TextButton(onPressed: _save, child: Text(texts.saveButton)),
      ],
    );
  }
}
