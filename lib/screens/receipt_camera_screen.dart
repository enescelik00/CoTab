import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import 'receipt_preview_screen.dart';

class ReceiptCameraScreen extends StatefulWidget {
  final Future<XFile?> Function()? takePhoto;

  const ReceiptCameraScreen({super.key, this.takePhoto});

  @override
  State<ReceiptCameraScreen> createState() => _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends State<ReceiptCameraScreen> {
  bool _isTakingPhoto = false;
  String? _error;

  Future<void> _takePhoto() async {
    final texts = AppLocalizations.of(context)!;
    setState(() {
      _isTakingPhoto = true;
      _error = null;
    });

    try {
      final photo = widget.takePhoto != null
          ? await widget.takePhoto!()
          : await ImagePicker().pickImage(source: ImageSource.camera);
      if (!mounted || photo == null) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPreviewScreen(photo: photo),
        ),
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _error =
              error.code == 'camera_access_denied' ||
                  error.code == 'camera_access_denied_without_prompt' ||
                  error.code == 'camera_access_restricted'
              ? texts.receiptCameraPermissionError
              : texts.receiptCameraUnavailable;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = texts.receiptCameraUnavailable);
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(texts.scanReceiptTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.document_scanner_outlined, size: 64),
              const SizedBox(height: 16),
              Text(texts.receiptCameraHint, textAlign: TextAlign.center),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              if (_isTakingPhoto)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(texts.receiptTakePhoto),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
