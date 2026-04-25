# frozen_string_literal: true

require "vips"

module Okmain
  module Sampler
    MAX_SAMPLE_SIZE = 250_000

    module_function

    # Returns [pixels, width, height] where pixels is an Array of [L, a, b] triples.
    def sample(input)
      image = if input.is_a?(Vips::Image)
                input
              else
                Vips::Image.new_from_file(input.to_s, access: :sequential)
              end

      # Flatten alpha to white background
      image = image.flatten(background: [255, 255, 255]) if image.has_alpha?

      # Convert to scRGB (linear float) for accurate block averaging
      image = image.colourspace(:scrgb)

      total = image.width * image.height
      block_size = compute_block_size(total)

      if block_size > 1
        # Claude wanted to do this in Ruby for a more-exact rust match, because apparently image.shrink
        # uses a slightly different algorithm, but an occasional 1 or 2 RGB value difference is a small
        # price for the huge speedup in letting VIPS do it for us.
        image = image.shrink(block_size, block_size)
      end

      width = image.width
      height = image.height

      # Claude's approach: Doing the colourspace translation ourselves
      # ==============================================================
      # Extract float pixel data [r, g, b] in linear space
      # floats = image.write_to_memory.unpack("f*")
      # bands = image.bands
      # pixel_count = width * height

      # pixels = Array.new(pixel_count)
      # i = 0
      # while i < pixel_count
      #   offset = i * bands
      #   r = floats[offset]
      #   g = floats[offset + 1]
      #   b = floats[offset + 2]
      #   pixels[i] = Oklab.linear_rgb_to_oklab(r, g, b)
      #   i += 1
      # end

      # My approach: more than twice as fast to let VIPS do it for us
      # =============================================================
      image = image.colourspace(:oklab)
      pixels = image.write_to_memory.unpack("f*").each_slice(3).to_a

      [pixels, width, height]
    end

    def compute_block_size(total)
      return 1 if total <= MAX_SAMPLE_SIZE

      bs = Math.sqrt(total.to_f / MAX_SAMPLE_SIZE).ceil
      # Round up to multiple of 4
      remainder = bs % 4
      bs += (4 - remainder) if remainder != 0
      bs
    end
  end
end
