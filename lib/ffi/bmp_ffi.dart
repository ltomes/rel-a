import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

/// FFI bindings for the Rust BMP generation library
class BmpFfi {
  static DynamicLibrary? _lib;

  /// Load the native library
  static DynamicLibrary get lib {
    if (_lib != null) return _lib!;

    if (Platform.isAndroid) {
      _lib = DynamicLibrary.open('librelaa_bmp.so');
    } else if (Platform.isLinux) {
      _lib = DynamicLibrary.open('librelaa_bmp.so');
    } else if (Platform.isMacOS) {
      _lib = DynamicLibrary.open('librelaa_bmp.dylib');
    } else if (Platform.isWindows) {
      _lib = DynamicLibrary.open('relaa_bmp.dll');
    } else {
      throw UnsupportedError('Platform not supported');
    }

    return _lib!;
  }

  /// Calculate the required BMP size
  ///
  /// Returns the total size in bytes needed for a BMP file
  static int calculateBmpSize(int width, int height) {
    final func = lib.lookupFunction<
        Int32 Function(Int32 width, Int32 height),
        int Function(int width, int height)
    >('calculate_bmp_size');

    return func(width, height);
  }

  /// Convert RGBA data to 1-bit monochrome
  ///
  /// [rgbaData] - Input RGBA image data
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  /// [skipHeader] - Number of bytes to skip at the beginning (e.g., BMP header)
  ///
  /// Returns the 1-bit bitmap data
  static Uint8List convertRgbaTo1Bit(
    Uint8List rgbaData,
    int width,
    int height,
    int skipHeader,
  ) {
    final func = lib.lookupFunction<
        Int32 Function(Pointer<Uint8> rgbaPtr, Int32 width, Int32 height, Int32 skipHeader, Pointer<Uint8> outPtr),
        int Function(Pointer<Uint8> rgbaPtr, int width, int height, int skipHeader, Pointer<Uint8> outPtr)
    >('convert_rgba_to_1bit');

    final bytesPerRow = width ~/ 8;
    final imageSize = bytesPerRow * height;
    final output = Uint8List(imageSize);

    final rgbaPtr = malloc.allocate<Uint8>(rgbaData.length);
    final outPtr = malloc.allocate<Uint8>(output.length);

    try {
      // Copy input data to native memory
      for (int i = 0; i < rgbaData.length; i++) {
        rgbaPtr[i] = rgbaData[i];
      }

      // Call Rust function
      final result = func(rgbaPtr, width, height, skipHeader, outPtr);

      if (result != 0) {
        throw Exception('Failed to convert RGBA to 1-bit: error code $result');
      }

      // Copy output data back to Dart
      for (int i = 0; i < output.length; i++) {
        output[i] = outPtr[i];
      }

      return output;
    } finally {
      malloc.free(rgbaPtr);
      malloc.free(outPtr);
    }
  }

  /// Build a 1-bit BMP file with headers
  ///
  /// [bitmapData] - The 1-bit bitmap data
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  ///
  /// Returns the complete BMP file as bytes
  static Uint8List build1BitBmp(
    Uint8List bitmapData,
    int width,
    int height,
  ) {
    final func = lib.lookupFunction<
        Int32 Function(Int32 width, Int32 height, Pointer<Uint8> bitmapDataPtr, Pointer<Uint8> outPtr),
        int Function(int width, int height, Pointer<Uint8> bitmapDataPtr, Pointer<Uint8> outPtr)
    >('build_1bit_bmp');

    final headerSize = 62;
    final bytesPerRow = width ~/ 8;
    final imageSize = bytesPerRow * height;
    final totalSize = headerSize + imageSize;
    final output = Uint8List(totalSize);

    final bitmapPtr = malloc.allocate<Uint8>(bitmapData.length);
    final outPtr = malloc.allocate<Uint8>(output.length);

    try {
      // Copy input data to native memory
      for (int i = 0; i < bitmapData.length; i++) {
        bitmapPtr[i] = bitmapData[i];
      }

      // Call Rust function
      final result = func(width, height, bitmapPtr, outPtr);

      if (result != 0) {
        throw Exception('Failed to build BMP: error code $result');
      }

      // Copy output data back to Dart
      for (int i = 0; i < output.length; i++) {
        output[i] = outPtr[i];
      }

      return output;
    } finally {
      malloc.free(bitmapPtr);
      malloc.free(outPtr);
    }
  }

  /// Generate a complete BMP file from RGBA data in one call
  ///
  /// [rgbaData] - Input RGBA image data
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  /// [skipHeader] - Number of bytes to skip at the beginning
  ///
  /// Returns the complete BMP file as bytes
  static Uint8List generateBmpFromRgba(
    Uint8List rgbaData,
    int width,
    int height,
    int skipHeader,
  ) {
    final func = lib.lookupFunction<
        Int32 Function(Pointer<Uint8> rgbaPtr, Int32 width, Int32 height, Int32 skipHeader, Pointer<Uint8> outPtr),
        int Function(Pointer<Uint8> rgbaPtr, int width, int height, int skipHeader, Pointer<Uint8> outPtr)
    >('generate_bmp_from_rgba');

    final size = calculateBmpSize(width, height);
    if (size < 0) {
      throw ArgumentError('Invalid dimensions: width=$width, height=$height');
    }

    final output = Uint8List(size);

    final rgbaPtr = malloc.allocate<Uint8>(rgbaData.length);
    final outPtr = malloc.allocate<Uint8>(output.length);

    try {
      // Copy input data to native memory
      for (int i = 0; i < rgbaData.length; i++) {
        rgbaPtr[i] = rgbaData[i];
      }

      // Call Rust function
      final result = func(rgbaPtr, width, height, skipHeader, outPtr);

      if (result != 0) {
        throw Exception('Failed to generate BMP: error code $result');
      }

      // Copy output data back to Dart
      for (int i = 0; i < output.length; i++) {
        output[i] = outPtr[i];
      }

      return output;
    } finally {
      malloc.free(rgbaPtr);
      malloc.free(outPtr);
    }
  }
}
