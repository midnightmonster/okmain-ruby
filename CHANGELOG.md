# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project might adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) if I ever get around to releasing a 1.0, but I wouldn't count on that happening any time soon.

## [Unreleased]

- May try to make KMeans faster: now that I have harvested the low-hanging fruit in sampler performance, kmeans is almost 90% of runtime on my test images.
- Adding a suite of test images and automating benchmarking new versions against old versions for speed and correctness would be cool.
- Even starting this project was AI psychosis. Would have been smarter to see if I like the output of the algorithm for the one specific thing I need this for first, no?

## [0.2.1] - 2026-04-25

### Added
- `Okmain::Oklab` conversion helpers needed by a downstream app:
  `srgb_to_linear`, `srgb8_to_oklab`, `oklab_to_oklch`, `oklch_to_oklab`,
  `srgb8_to_oklch`. Hue is in degrees, normalized to `[0, 360)`.

## [0.2.0] - 2026-04-25

### Changed
- RNG replaced with a Xoshiro256++ implementation matching the upstream Rust
  `okmain` crate, so results closely track the reference implementation.
  Output for a given image will differ from 0.1.0.
- Sampler, distance mask, scorer, and Oklab conversion paths reworked for
  speed and closer parity with the Rust implementation.

### Added
- `Okmain::Xoshiro` PRNG (`lib/okmain/xoshiro.rb`).
- `bench.rb` benchmark script and a `rust_compare/` companion crate for
  apples-to-apples timing and output comparisons against the Rust crate.
- `Rakefile` exposing the standard `bundler/gem_tasks` (`build`, `install`,
  `release`).
- Development dependencies: `benchmark ~> 0.4`, `rake ~> 13.0`.

## [0.1.0] - 2026-04-24

### Added
- Initial port of the Rust `okmain` crate to Ruby: extracts up to 4 dominant
  colors from an image via adaptive K-means clustering in Oklab space.
- `ruby-vips`-based image loading with block-average downsampling.
- Dual MIT / Apache-2.0 licensing matching the upstream crate.
- README with install and usage examples.

[Unreleased]: https://github.com/midnightmonster/okmain-ruby/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/midnightmonster/okmain-ruby/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/midnightmonster/okmain-ruby/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/midnightmonster/okmain-ruby/releases/tag/v0.1.0
