import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../services/receipt_ocr_service.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final XFile photo;
  final Future<String> Function(String)? readText;
  final bool fromGallery;

  const ReceiptPreviewScreen({
    super.key,
    required this.photo,
    this.readText,
    this.fromGallery = false,
  });

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  bool _isReading = false;
  String? _recognizedText;
  String? _error;

  Future<void> _readText() async {
    final texts = AppLocalizations.of(context)!;
    setState(() {
      _isReading = true;
      _error = null;
      _recognizedText = null;
    });
    try {
      final result = await (widget.readText ?? readReceiptText)(
        widget.photo.path,
      );
      if (mounted) setState(() => _recognizedText = result.trim());
    } catch (_) {
      if (mounted) setState(() => _error = texts.receiptOcrError);
    } finally {
      if (mounted) setState(() => _isReading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(texts.receiptPreviewTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.photo.path),
              height: 320,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Text(texts.receiptImageError),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _isReading ? null : () => Navigator.pop(context),
            child: Text(
              widget.fromGallery
                  ? texts.receiptChooseAnother
                  : texts.receiptRetake,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isReading ? null : _readText,
            child: Text(texts.receiptReadText),
          ),
          if (_isReading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_recognizedText != null) ...[
            const SizedBox(height: 24),
            Text(
              texts.receiptRecognizedText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              _recognizedText!.isEmpty ? texts.receiptNoText : _recognizedText!,
            ),
          ],
        ],
      ),
    );
  }
}
