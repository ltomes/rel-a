import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:relaa/ffi/bmp_ffi.dart';

/// Generate a demo BMP using Rust FFI
Future<Uint8List> generateDemoBMPRust() async {
  const canvasWidth = 576;
  const canvasHeight = 136;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Draw background (white)
  final backgroundPaint = ui.Paint()
    ..color = const ui.Color.fromARGB(255, 255, 255, 255);
  canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
      backgroundPaint);

  // Draw text in black
  final textStyle =
      ui.TextStyle(color: ui.Color.fromARGB(255, 0, 0, 0), fontSize: 24);
  final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center);
  final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
    ..pushStyle(textStyle)
    ..addText("Hello World!");

  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: canvasWidth.toDouble()));
  canvas.drawParagraph(paragraph, ui.Offset(0, canvasHeight / 2));

  // Convert to an image
  final picture = recorder.endRecording();
  final image = await picture.toImage(canvasWidth, canvasHeight);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgbaData = byteData!.buffer.asUint8List();

  // Use Rust FFI to generate BMP
  final bmpBytes = BmpFfi.generateBmpFromRgba(
    rgbaData,
    canvasWidth,
    canvasHeight,
    0, // No header to skip for raw RGBA
  );

  return bmpBytes;
}

/// Generate a navigation BMP using Rust FFI
Future<Uint8List> generateNavigationBMPRust(
    String maneuver, double distance) async {
  const canvasWidth = 576;
  const canvasHeight = 136;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);

  // Draw background (black)
  final backgroundPaint = ui.Paint()..color = const ui.Color(0xFF000000);
  canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()),
      backgroundPaint);

  // Draw icon
  final iconData = await _loadManeuverIcon(maneuver);
  if (iconData != null) {
    final ui.Image image = await decodeImage(iconData);
    final iconSize = 80.0;
    final iconRect = ui.Rect.fromCenter(
      center: ui.Offset(canvasWidth / 2, canvasHeight / 3),
      width: iconSize,
      height: iconSize,
    );
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      iconRect,
      ui.Paint(),
    );
  }

  // Draw distance text in white
  final textStyle = ui.TextStyle(color: ui.Color(0xFFFFFFFF), fontSize: 24);
  final paragraphStyle = ui.ParagraphStyle(textAlign: ui.TextAlign.center);
  final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
    ..pushStyle(textStyle)
    ..addText("${distance.toStringAsFixed(1)} m");
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: canvasWidth.toDouble()));
  canvas.drawParagraph(paragraph, ui.Offset(0, canvasHeight * 0.7));

  // Convert to an image
  final picture = recorder.endRecording();
  final image = await picture.toImage(canvasWidth, canvasHeight);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final rgbaData = byteData!.buffer.asUint8List();

  // Use Rust FFI to generate BMP
  final bmpBytes = BmpFfi.generateBmpFromRgba(
    rgbaData,
    canvasWidth,
    canvasHeight,
    0, // No header to skip for raw RGBA
  );

  // Save BMP temporarily to disk for debugging
  await _saveBitmapToDisk(bmpBytes, 'navigation_rust.bmp');

  return bmpBytes;
}

// Load and decode image
Future<ui.Image> decodeImage(Uint8List imageData) async {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(imageData, completer.complete);
  return completer.future;
}

Future<Uint8List?> _loadManeuverIcon(String maneuver) async {
  final iconPath = 'assets/icons/$maneuver.png';
  try {
    final data = await rootBundle.load(iconPath);
    return data.buffer.asUint8List();
  } catch (e) {
    print("Error loading icon: $e");
    return null;
  }
}

/// Save bitmap to disk for debugging purposes
Future<void> _saveBitmapToDisk(Uint8List bmpData, String fileName) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bmpData);
    print('Bitmap saved temporarily at $filePath');
  } catch (e) {
    print('Error saving bitmap to disk: $e');
  }
}

/// Generate BMP for display from PNG image using Rust FFI
///
/// This is the main function that replaces the Dart implementation
Future<Uint8List> generateBMPForDisplayRust(
    Uint8List pngImage, int canvasWidth, int canvasHeight) async {
  // Convert PNG to 32-bit BMP first
  final bmp32Image = await pngImage.bmpUint8List;

  // Use Rust FFI to convert to 1-bit BMP
  // Skip 139 bytes header (same as original Dart implementation)
  final bmpBytes = BmpFfi.generateBmpFromRgba(
    bmp32Image,
    canvasWidth,
    canvasHeight,
    139, // Skip BMP header bytes
  );

  return bmpBytes;
}
