import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import 'receipt_preview_screen.dart';

class ReceiptCameraScreen extends StatefulWidget {
  final Future<XFile?> Function(ImageSource)? pickImage;

  const ReceiptCameraScreen({super.key, this.pickImage});

  @override
  State<ReceiptCameraScreen> createState() => _ReceiptCameraScreenState();
}

class _ReceiptCameraScreenState extends State<ReceiptCameraScreen> {
  bool _isPickingImage = false;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final texts = AppLocalizations.of(context)!;
    setState(() {
      _isPickingImage = true;
      _error = null;
    });

    try {
      final photo = widget.pickImage != null
          ? await widget.pickImage!(source)
          : await ImagePicker().pickImage(source: source);
      if (!mounted || photo == null) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPreviewScreen(
            photo: photo,
            fromGallery: source == ImageSource.gallery,
          ),
        ),
      );
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          if (source == ImageSource.gallery) {
            _error = error.code == 'photo_access_denied'
                ? texts.receiptGalleryPermissionError
                : texts.receiptGalleryUnavailable;
          } else {
            _error =
                error.code == 'camera_access_denied' ||
                    error.code == 'camera_access_denied_without_prompt' ||
                    error.code == 'camera_access_restricted'
                ? texts.receiptCameraPermissionError
                : texts.receiptCameraUnavailable;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = source == ImageSource.gallery
              ? texts.receiptGalleryUnavailable
              : texts.receiptCameraUnavailable,
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
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
              if (_isPickingImage)
                const CircularProgressIndicator()
              else ...[
                FilledButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(texts.receiptTakePhoto),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(texts.receiptChooseFromGallery),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
