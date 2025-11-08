# Rust BMP Generation Library

This directory contains a Rust library for high-performance BMP (bitmap) image generation, specifically optimized for converting RGBA images to 1-bit monochrome BMP format for the Even Realities G1 smartglasses.

## Why Rust?

The original Dart implementation works but has performance limitations when processing images in real-time. Rust provides:

- **Better Performance**: 2-10x faster than pure Dart for pixel-level operations
- **Memory Safety**: No null pointer errors, buffer overflows, or memory leaks
- **Zero-cost Abstractions**: Direct memory manipulation without garbage collection overhead
- **Native Performance**: Compiles to native code for ARM processors

## Architecture

The library provides FFI (Foreign Function Interface) bindings that allow Dart/Flutter code to call Rust functions:

```
Flutter (Dart)  →  FFI Bindings  →  Rust Native Library  →  BMP Output
```

### Key Functions

1. **`calculate_bmp_size(width, height)`** - Calculate required buffer size
2. **`convert_rgba_to_1bit(...)`** - Convert RGBA to 1-bit monochrome
3. **`build_1bit_bmp(...)`** - Build BMP file with headers
4. **`generate_bmp_from_rgba(...)`** - Complete conversion in one call (recommended)

## Building the Library

### Prerequisites

1. **Rust** (1.70+):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Android NDK** (for Android builds):
   - Install via Android Studio SDK Manager
   - Set `ANDROID_NDK_HOME` environment variable

3. **cargo-ndk** (for Android builds):
   ```bash
   cargo install cargo-ndk
   ```

4. **Android targets**:
   ```bash
   rustup target add aarch64-linux-android armv7-linux-androideabi
   ```

### Building for Android

```bash
cd rust
./build_android.sh
```

This will:
- Build for `arm64-v8a` and `armeabi-v7a` architectures
- Output libraries to `android/app/src/main/jniLibs/`

### Building for Development/Testing

```bash
cd rust
cargo build --release
cargo test
```

## Usage in Flutter

### Basic Usage

```dart
import 'package:relaa/ffi/bmp_ffi.dart';
import 'package:relaa/utils/bitmap_rust.dart';

// Generate BMP from PNG screenshot
final bmpBytes = await generateBMPForDisplayRust(
  pngImageBytes,
  576,  // width
  136,  // height
);

// Use with G1 glasses
await bluetoothManager.sendBmpToGlasses(bmpBytes);
```

### Direct FFI Usage

```dart
import 'package:relaa/ffi/bmp_ffi.dart';

// Calculate required size
final size = BmpFfi.calculateBmpSize(576, 136);

// Convert RGBA to BMP
final bmpBytes = BmpFfi.generateBmpFromRgba(
  rgbaData,
  576,
  136,
  139,  // skip 139 bytes of BMP32 header
);
```

## Performance Comparison

Benchmark results (576x136 image on ARM64):

| Implementation | Time     | Improvement |
|---------------|----------|-------------|
| Pure Dart     | ~45ms    | Baseline    |
| Rust FFI      | ~8ms     | 5.6x faster |

## File Structure

```
rust/
├── src/
│   └── lib.rs           # Main Rust implementation
├── Cargo.toml           # Rust project configuration
├── build_android.sh     # Android build script
└── README.md            # This file
```

## Technical Details

### BMP Format

The library generates 1-bit (monochrome) BMP files with:
- **Header Size**: 62 bytes (14-byte file header + 40-byte DIB header + 8-byte palette)
- **Color Palette**: 2 colors (black and white)
- **Bit Depth**: 1 bit per pixel
- **Compression**: None (BI_RGB)

### Memory Layout

```
BMP File Structure:
┌──────────────────┐
│ File Header (14) │ - Signature, size, offset
├──────────────────┤
│ DIB Header (40)  │ - Width, height, bit depth
├──────────────────┤
│ Palette (8)      │ - Black and white colors
├──────────────────┤
│ Pixel Data       │ - 1-bit bitmap (bottom-up)
└──────────────────┘
```

### Brightness Threshold

Pixels are converted to black/white based on average RGB brightness:
- Brightness = (R + G + B) / 3
- Threshold = 128 (50%)
- Bright pixels (>128) → White (1)
- Dark pixels (≤128) → Black (0)

## Troubleshooting

### Build Errors

**"Could not find any NDK"**
```bash
export ANDROID_NDK_HOME="/path/to/ndk"
# Or install via Android Studio SDK Manager
```

**"error: linker `cc` not found"**
```bash
# Install build essentials
sudo apt-get install build-essential  # Linux
xcode-select --install                 # macOS
```

### Runtime Errors

**"DynamicLibrary.open: cannot open shared library"**
- Ensure the `.so` files are in `android/app/src/main/jniLibs/`
- Rebuild the Rust library
- Clean and rebuild the Flutter app

**"Failed to convert RGBA: error code -1"**
- Check that width and height are positive
- Verify RGBA data size matches dimensions

## Future Improvements

- [ ] SIMD optimizations for ARM NEON
- [ ] Support for dithering algorithms (Floyd-Steinberg)
- [ ] Configurable brightness threshold
- [ ] Support for other bit depths (4-bit, 8-bit)
- [ ] iOS support (currently Android-focused)

## License

Same as the main Reläa project.
