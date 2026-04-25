# frozen_string_literal: true

module Okmain
  module DistanceMask
    module_function

    # Returns a flat Array of mask values (0.1..1.0) for each pixel,
    # matching the Rust rectangular mask exactly.
    # Center pixels get 1.0, corner pixels get 0.1, with a linear ramp.
    def compute(width, height, saturated_threshold)
      w = width.to_f
      h = height.to_f
      middle_x = w / 2.0
      middle_y = h / 2.0
      x_threshold = w * saturated_threshold
      y_threshold = h * saturated_threshold

      mask = Array.new(width * height)
      y = 0
      while y < height
        yf = y.to_f
        my = yf <= middle_y ? yf : h - yf
        y_contrib = if y_threshold > 0.0
                      v = 0.1 + 0.9 * (my / y_threshold)
                      v < 1.0 ? v : 1.0
                    else
                      1.0
                    end

        row_offset = y * width
        x = 0
        while x < width
          xf = x.to_f
          mx = xf <= middle_x ? xf : w - xf
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
