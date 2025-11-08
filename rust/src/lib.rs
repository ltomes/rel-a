use std::slice;

/// Converts RGBA image data to 1-bit monochrome BMP format
///
/// # Safety
/// This function is unsafe because it deals with raw pointers from FFI
/// The caller must ensure:
/// - rgba_ptr points to valid memory of at least width * height * 4 bytes
/// - out_ptr points to valid memory of at least width * height / 8 bytes
#[no_mangle]
pub unsafe extern "C" fn convert_rgba_to_1bit(
    rgba_ptr: *const u8,
    width: i32,
    height: i32,
    skip_header: i32,
    out_ptr: *mut u8,
) -> i32 {
    if rgba_ptr.is_null() || out_ptr.is_null() {
        return -1;
    }

    if width <= 0 || height <= 0 {
        return -2;
    }

    let width = width as usize;
    let height = height as usize;
    let skip_header = skip_header as usize;

    let total_rgba_len = width * height * 4 + skip_header;
    let rgba = slice::from_raw_parts(rgba_ptr, total_rgba_len);

    // Skip header bytes (e.g., 139 bytes from the original Dart code)
    let rgba_data = &rgba[skip_header..];

    let bytes_per_row = width / 8;
    let output = slice::from_raw_parts_mut(out_ptr, bytes_per_row * height);

    // Initialize output to zero
    for byte in output.iter_mut() {
        *byte = 0;
    }

    // Convert RGBA to 1-bit, processing from bottom to top (BMP format)
    for y in 0..height {
        let flipped_y = height - 1 - y;

        for x in 0..width {
            let rgba_index = (flipped_y * width + x) * 4;

            // Ensure we don't go out of bounds
            if rgba_index + 2 >= rgba_data.len() {
                continue;
            }

            let r = rgba_data[rgba_index] as u32;
            let g = rgba_data[rgba_index + 1] as u32;
            let b = rgba_data[rgba_index + 2] as u32;

            // Calculate brightness (average of RGB)
            let brightness = (r + g + b) / 3;

            // Threshold at 128 (50% brightness)
            let bit = if brightness > 128 { 1u8 } else { 0u8 };

            // Set the bit in the output
            let out_row_start = y * bytes_per_row;
            let byte_index = out_row_start + (x / 8);
            let bit_offset = 7 - (x % 8);

            output[byte_index] |= bit << bit_offset;
        }
    }

    0 // Success
}

/// Builds a complete 1-bit BMP file with headers
///
/// # Safety
/// This function is unsafe because it deals with raw pointers from FFI
/// The caller must ensure:
/// - bitmap_data_ptr points to valid memory of at least (width * height / 8) bytes
/// - out_ptr points to valid memory of at least (62 + width * height / 8) bytes
#[no_mangle]
pub unsafe extern "C" fn build_1bit_bmp(
    width: i32,
    height: i32,
    bitmap_data_ptr: *const u8,
    out_ptr: *mut u8,
) -> i32 {
    if bitmap_data_ptr.is_null() || out_ptr.is_null() {
        return -1;
    }

    if width <= 0 || height <= 0 {
        return -2;
    }

    let width = width as usize;
    let height = height as usize;

    let header_size = 62;
    let bytes_per_row = width / 8;
    let image_size = bytes_per_row * height;
    let file_size = header_size + image_size;

    let bitmap_data = slice::from_raw_parts(bitmap_data_ptr, image_size);
    let output = slice::from_raw_parts_mut(out_ptr, file_size);

    let mut cursor = 0;

    // BMP File Header (14 bytes)
    output[cursor] = 0x42; // 'B'
    cursor += 1;
    output[cursor] = 0x4D; // 'M'
    cursor += 1;

    // File size (4 bytes, little-endian)
    write_u32_le(&mut output[cursor..], file_size as u32);
    cursor += 4;

    // Reserved (4 bytes)
    write_u32_le(&mut output[cursor..], 0);
    cursor += 4;

    // Offset to pixel data (4 bytes)
    write_u32_le(&mut output[cursor..], header_size as u32);
    cursor += 4;

    // DIB Header (BITMAPINFOHEADER - 40 bytes)

    // Header size (4 bytes)
    write_u32_le(&mut output[cursor..], 40);
    cursor += 4;

    // Width (4 bytes)
    write_i32_le(&mut output[cursor..], width as i32);
    cursor += 4;

    // Height (4 bytes)
    write_i32_le(&mut output[cursor..], height as i32);
    cursor += 4;

    // Planes (2 bytes) - must be 1
    write_u16_le(&mut output[cursor..], 1);
    cursor += 2;

    // Bits per pixel (2 bytes) - 1 for monochrome
    write_u16_le(&mut output[cursor..], 1);
    cursor += 2;

    // Compression (4 bytes) - 0 for uncompressed
    write_u32_le(&mut output[cursor..], 0);
    cursor += 4;

    // Image size (4 bytes) - can be 0 for uncompressed
    write_u32_le(&mut output[cursor..], 0);
    cursor += 4;

    // X pixels per meter (4 bytes)
    write_u32_le(&mut output[cursor..], 0);
    cursor += 4;

    // Y pixels per meter (4 bytes)
    write_u32_le(&mut output[cursor..], 0);
    cursor += 4;

    // Colors used (4 bytes) - 2 for monochrome
    write_u32_le(&mut output[cursor..], 2);
    cursor += 4;

    // Important colors (4 bytes) - 2 for monochrome
    write_u32_le(&mut output[cursor..], 2);
    cursor += 4;

    // Color palette (8 bytes - 2 colors * 4 bytes each)
    // Black (BGRA format)
    output[cursor] = 0x00; // Blue
    output[cursor + 1] = 0x00; // Green
    output[cursor + 2] = 0x00; // Red
    output[cursor + 3] = 0x00; // Reserved
    cursor += 4;

    // White (BGRA format)
    output[cursor] = 0xFF; // Blue
    output[cursor + 1] = 0xFF; // Green
    output[cursor + 2] = 0xFF; // Red
    output[cursor + 3] = 0x00; // Reserved
    cursor += 4;

    // Copy bitmap data
    output[cursor..].copy_from_slice(bitmap_data);

    0 // Success
}

/// Complete BMP generation from RGBA data
/// Combines conversion and header building in one call
///
/// # Safety
/// This function is unsafe because it deals with raw pointers from FFI
/// The caller must ensure:
/// - rgba_ptr points to valid memory
/// - out_ptr points to valid memory of sufficient size
#[no_mangle]
pub unsafe extern "C" fn generate_bmp_from_rgba(
    rgba_ptr: *const u8,
    width: i32,
    height: i32,
    skip_header: i32,
    out_ptr: *mut u8,
) -> i32 {
    if rgba_ptr.is_null() || out_ptr.is_null() {
        return -1;
    }

    if width <= 0 || height <= 0 {
        return -2;
    }

    let width = width as usize;
    let height = height as usize;

    let bytes_per_row = width / 8;
    let image_size = bytes_per_row * height;
    let header_size = 62;
    let total_size = header_size + image_size;

    // Allocate temporary buffer for 1-bit data
    let mut temp_buffer = vec![0u8; image_size];

    // Convert RGBA to 1-bit
    let result = convert_rgba_to_1bit(
        rgba_ptr,
        width as i32,
        height as i32,
        skip_header,
        temp_buffer.as_mut_ptr(),
    );

    if result != 0 {
        return result;
    }

    // Build BMP file
    build_1bit_bmp(
        width as i32,
        height as i32,
        temp_buffer.as_ptr(),
        out_ptr,
    )
}

/// Calculate the required output buffer size for a BMP
#[no_mangle]
pub extern "C" fn calculate_bmp_size(width: i32, height: i32) -> i32 {
    if width <= 0 || height <= 0 {
        return -1;
    }

    let width = width as usize;
    let height = height as usize;
    let header_size = 62;
    let bytes_per_row = width / 8;
    let image_size = bytes_per_row * height;

    (header_size + image_size) as i32
}

// Helper functions for writing multi-byte values in little-endian format

fn write_u16_le(buf: &mut [u8], value: u16) {
    buf[0] = (value & 0xFF) as u8;
    buf[1] = ((value >> 8) & 0xFF) as u8;
}

fn write_u32_le(buf: &mut [u8], value: u32) {
    buf[0] = (value & 0xFF) as u8;
    buf[1] = ((value >> 8) & 0xFF) as u8;
    buf[2] = ((value >> 16) & 0xFF) as u8;
    buf[3] = ((value >> 24) & 0xFF) as u8;
}

fn write_i32_le(buf: &mut [u8], value: i32) {
    write_u32_le(buf, value as u32);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_bmp_size() {
        let size = calculate_bmp_size(576, 136);
        assert_eq!(size, 62 + (576 / 8) * 136);
    }

    #[test]
    fn test_invalid_dimensions() {
        assert_eq!(calculate_bmp_size(-1, 100), -1);
        assert_eq!(calculate_bmp_size(100, 0), -1);
    }
}
