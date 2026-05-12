# Changelog

## Unreleased

- Fixed ready-check role marking by restoring a secure click prompt, which is required by WoW's protected raid-marker API.
- Updated README wording for the ready-check marker behavior.

## v1.0.1

- Added clearer README quick start instructions.
- Documented the generated `AutoFocus`, `AutoKick`, and `AutoStop` macro bodies.
- Updated CurseForge packaging to use this manual changelog.

## v1.0.0

- Initial release.
- Automatically creates and updates `AutoFocus`, `AutoKick`, and `AutoStop`.
- Uses class/spec-aware interrupt and stop spells.
- Marks tank and healer on ready check when they do not already have markers.
