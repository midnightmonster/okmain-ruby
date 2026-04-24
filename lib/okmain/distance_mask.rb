# frozen_string_literal: true

module Okmain
  module DistanceMask
    SATURATED_THRESHOLD = 0.75

    module_function

    # Returns a flat Array of mask values (0.1..1.0) for each pixel, matching Rust's rectangular mask.
    # Center pixels get 1.0, corner pixels get 0.1, with a linear ramp.
    def compute(width, height)
      half_w = width * 0.5
      half_h = height * 0.5
      x_threshold = half_w * SATURATED_THRESHOLD
      y_threshold = half_h * SATURATED_THRESHOLD

      mask = Array.new(width * height)
      y = 0
      while y < height
        # Distance from nearest y-edge (0 at edge, half_h at center)
        my = y < half_h ? y.to_f : (height - 1 - y).to_f
        y_contrib = if y_threshold > 0.0
                      v = 0.1 + 0.9 * (my / y_threshold)
                      v < 1.0 ? v : 1.0
                    else
                      1.0
                    end

        row_offset = y * width
        x = 0
        while x < width
          # Distance from nearest x-edge (0 at edge, half_w at center)
          mx = x < half_w ? x.to_f : (width - 1 - x).to_f
          x_contrib = if x_threshold > 0.0
                        v = 0.1 + 0.9 * (mx / x_threshold)
                        v < 1.0 ? v : 1.0
                      else
                        1.0
                      end

          mask[row_offset + x] = x_contrib < y_contrib ? x_contrib : y_contrib
          x += 1
        end
        y += 1
      end

      mask
    end
  end
end
