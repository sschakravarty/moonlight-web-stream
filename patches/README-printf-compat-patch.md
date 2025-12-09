# Patch for printf-compat crate to fix VaList API for new Rust nightly

# Steps:
# 1. Download the printf-compat crate source (version 0.2.1)
# 2. Edit src/output.rs:
#    - Change all `VaList<'a, 'b>` to `VaList<'a>`
#    - Change all `VaListDisplay<'a, 'b>` to `VaListDisplay<'a>`
#    - Remove `'b` lifetime from function signatures and struct definitions as needed
# 3. Point Cargo.toml to this local patched version using [patch.crates-io]

# Example patch (not the full patch):
# -    va_list: VaList<'a, 'b>,
# +    va_list: VaList<'a>,

# -) -> VaListDisplay<'a, 'b> {
# +) -> VaListDisplay<'a> {

# After patching, add to your Cargo.toml:
# [patch.crates-io]
# printf-compat = { path = "../patches/printf-compat" }
