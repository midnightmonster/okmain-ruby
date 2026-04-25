# okmain

A Ruby gem that extracts dominant colors from images using adaptive K-means clustering in the [Oklab](https://bottosson.github.io/posts/oklab/) perceptual color space.

This is a port of the Rust [okmain](https://github.com/si14/okmain) crate by [Dan Groshev](https://github.com/si14). See also his [blog post](https://dgroshev.com/blog/okmain/) about the project.

## Installation

Add to your Gemfile:

```ruby
gem "okmain"
```

Or install directly:

```
gem install okmain
```

Requires [libvips](https://www.libvips.org/) to be installed on your system:

```
# macOS
brew install vips

# Debian/Ubuntu
apt install libvips-dev

# Fedora
dnf install vips-devel
```

## Usage

```ruby
require "okmain"

# Extract up to 4 dominant colors from an image file
colors = Okmain.colors("photo.jpg")
# => [[r, g, b], [r, g, b], ...]

# Also accepts a Vips::Image
require "vips"
image = Vips::Image.new_from_file("photo.jpg")
colors = Okmain.colors(image)

# Customize scoring weights
config = Okmain::Config.new(
  chroma_weight: 0.5,              # weight for color vividness (default: 0.7)
  mask_weighted_counts_weight: 0.5  # weight for pixel count/position (default: 0.3)
)
colors = Okmain.colors("photo.jpg", config: config)
```

Colors are returned as `[r, g, b]` arrays (0-255), sorted by score descending. The number of colors returned (up to 4) is determined adaptively — similar clusters are merged.

## How it works

1. **Sample** — Large images are block-averaged down to ~250k pixels using libvips, then converted from sRGB to Oklab
2. **Cluster** — Adaptive K-means in Oklab space (K-means++ initialization, Lloyd's iterations, merging similar centroids)
3. **Score** — Centroids ranked by a weighted combination of pixel count (with center-priority mask) and chroma
4. **Return** — Up to 4 `[r, g, b]` arrays sorted by score

## Comparing with the Rust implementation

A small Rust binary is included in `rust_compare/` for verifying results against the original [okmain](https://github.com/si14/okmain) crate. Requires [Rust](https://rustup.rs/) 1.93+.

Build it once:

```
cd rust_compare
cargo build --release
```

Then compare outputs on any image:

```bash
# Rust
rust_compare/target/release/rust_compare path/to/photo.jpg

# Ruby
bundle exec ruby -e "require 'okmain'; pp Okmain.colors('path/to/photo.jpg')"
```

Both print `[r, g, b]` arrays in the same order, so results can be diffed directly.

For benchmarking (against rust, but mostly to catch progress or regression in the gem), use:

```bash
bundle exec ruby bench.rb path/to/image.png
```

## Credits

Based on the Rust [okmain](https://github.com/si14/okmain) crate (v0.2.0) by Dan Groshev and okmain contributors.

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT License ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.
