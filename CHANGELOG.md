# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-07-01

### Added

- `@doc` annotations with doctests for public API functions (`image/5`,
  `svg_group/5`, `create/6`).
- Expanded `@moduledoc` with curvature documentation and usage guidance.
- CHANGELOG.md in Keep a Changelog format.

### Changed

- `squircle_path/3`, `squircle_path_d/3`, and `wrap/5` made private (they
  are internal implementation details).

### Fixed

- Char list deprecation warning (`'...'` → `~c"..."`) in `gen_random_string/1`.

## [0.1.1] — 2026-07-01

### Added

- credo configuration for code quality checks.
- `:reach` dev dependency for cross-function smell detection.
- SPDX license headers in all source files.
- Link to [obidenticon demo](https://obidenticon.overbring.com/) in README.

### Fixed

- Squircle path was not formally closed with `Z` in all cases.
- SVG output used `version="1.2"` — corrected to `version="1.1"` for browser
  compatibility.
- Empty `transform=""` attribute was emitted when no padding or rotation
  was provided — now omitted.
- Stub test replaced with real functional tests covering curvature bounds,
  SVG version, transform attribute, path closure, and output structure.
- `is_bitstring/1` replaced with `is_binary/1` (deprecated in recent Elixir).
- Curvature values outside `0.0..1.0` properly rejected via guard clause.

### Changed

- Erlang/OTP updated to 29.0.1, Elixir to 1.20.1.
- `shape-rendering` set to `auto` for better visual quality.

## [0.1.0] — 2024-08-12

### Added

- Initial release.
- `image/5` generates a full SVG document wrapping an image URL in a squircle.
- `svg_group/5` generates a full SVG document wrapping SVG content in a squircle.
- `create/6` returns raw squircle path primitives for custom integrations.
- Parametrizable curvature from 0.0 (sharp) to 1.0 (circle).
- Optional padding.
- Optional rotation.
- Optional pattern ID for use in `<defs>`.
