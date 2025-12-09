# Build Fixes for Rust Nightly Compatibility

This document outlines the fixes applied to make the project build successfully with Rust nightly.

## Issues Fixed

### 1. Printf-compat VaList API Compatibility

**Problem**: The `printf-compat` crate was using an outdated VaList API that's incompatible with current Rust nightly:
- `VaList<'a, 'b>` → now only supports `VaList<'a>` 
- `VaListDisplay<'a, 'b>` → now only supports `VaListDisplay<'a>`
- `.as_va_list()` method → no longer exists, pass VaList directly

**Solution**: Created a local patch in `./patches/printf-compat/` with the following changes:
- Updated all struct definitions to use single lifetime parameter
- Removed `.as_va_list()` calls in source code and tests
- Added `[patch.crates-io]` entry in `Cargo.toml` to use local patch

### 2. Missing Git Submodules

**Problem**: Build failed due to missing `moonlight-common-c` submodule and its nested dependencies.

**Solution**: Initialize all submodules recursively:
```bash
git submodule update --init --recursive
```

### 3. Missing System Dependencies  

**Problem**: Build failed due to missing pkg-config and OpenSSL development libraries.

**Solution**: Install required packages:
```bash
sudo apt-get install -y pkg-config libssl-dev
```

## Build Instructions

1. Install Rust nightly:
   ```bash
   rustup toolchain install nightly
   rustup override set nightly
   ```

2. Install system dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y pkg-config libssl-dev
   ```

3. Initialize submodules:
   ```bash
   git submodule update --init --recursive
   ```

4. Build the project:
   ```bash
   cargo build --release
   ```

## Files Modified

- `Cargo.toml` - Added patch configuration for printf-compat
- `patches/printf-compat/src/output.rs` - Fixed VaList API compatibility
- `patches/printf-compat/src/lib.rs` - Updated documentation examples
- `patches/printf-compat/tests/tests.rs` - Fixed test code
- `moonlight-common/src/stream/connection.rs` - Removed deprecated as_va_list() call