import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cotab/main.dart';
import 'package:cotab/screens/receipt_camera_screen.dart';
import 'package:cotab/screens/receipt_preview_screen.dart';

void main() {
  testWidgets('Camera permission error is shown', (tester) async {
    await tester.pumpWidget(
      CoTabApp(
        home: ReceiptCameraScreen(
          takePhoto: () async =>
              throw PlatformException(code: 'camera_access_denied'),
        ),
      ),
    );

    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Camera access is denied'), findsOneWidget);
  });

  testWidgets('Unavailable camera error is shown', (tester) async {
    await tester.pumpWidget(
      CoTabApp(
        home: ReceiptCameraScreen(
          takePhoto: () async =>
              throw PlatformException(code: 'camera_unavailable'),
        ),
      ),
    );

    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('camera could not be opened'), findsOneWidget);
  });

  testWidgets('OCR failure does not close the preview', (tester) async {
    await tester.pumpWidget(
      CoTabApp(
        home: ReceiptPreviewScreen(
          photo: XFile('missing-receipt.jpg'),
          readText: (_) async => throw Exception('OCR failed'),
        ),
      ),
    );

    await tester.tap(find.text('Read text'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('receipt text could not be read'),
      findsOneWidget,
    );
    expect(find.text('Retake photo'), findsOneWidget);
  });

  testWidgets('No OCR text shows a retry hint', (tester) async {
    await tester.pumpWidget(CoTabApp(
      home: ReceiptPreviewScreen(
        photo: XFile('missing-receipt.jpg'),
        readText: (_) async => '  ',
      ),
    ));

    await tester.tap(find.text('Read text'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No text was found'), findsOneWidget);
  });
}
