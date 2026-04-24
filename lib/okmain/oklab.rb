# frozen_string_literal: true

module Okmain
  module Oklab
    module_function

    # Linear RGB (0..1) → Oklab [L, a, b]
    def linear_rgb_to_oklab(r, g, b)
      l_ = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
      m_ = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
      s_ = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

      l_cbrt = Math.cbrt(l_)
      m_cbrt = Math.cbrt(m_)
      s_cbrt = Math.cbrt(s_)

      l = 0.2104542553 * l_cbrt + 0.7936177850 * m_cbrt - 0.0040720468 * s_cbrt
      a = 1.9779984951 * l_cbrt - 2.4285922050 * m_cbrt + 0.4505937099 * s_cbrt
      b_ = 0.0259040371 * l_cbrt + 0.7827717662 * m_cbrt - 0.8086757660 * s_cbrt

      [l, a, b_]
    end

    # Oklab [L, a, b] → linear RGB (0..1)
    def oklab_to_linear_rgb(l, a, b)
      l_ = l + 0.3963377774 * a + 0.2158037573 * b
      m_ = l - 0.1055613458 * a - 0.0638541728 * b
      s_ = l - 0.0894841775 * a - 1.2914855480 * b

      l_cubed = l_ * l_ * l_
      m_cubed = m_ * m_ * m_
      s_cubed = s_ * s_ * s_

      r =  4.0767416621 * l_cubed - 3.3077115913 * m_cubed + 0.2309699292 * s_cubed
      g = -1.2684380046 * l_cubed + 2.6097574011 * m_cubed - 0.3413193965 * s_cubed
      b_ = -0.0041960863 * l_cubed - 0.7034186147 * m_cubed + 1.7076147010 * s_cubed

      [r, g, b_]
    end

    # sRGB component (0..255) → linear (0..1)
    def srgb_to_linear(c)
      c = c / 255.0
      if c <= 0.04045
        c / 12.92
      else
        ((c + 0.055) / 1.055)**2.4
      end
    end

    # Linear (0..1) → sRGB component (0..255), clamped
    def linear_to_srgb(c)
      c = c.clamp(0.0, 1.0)
      c = if c <= 0.0031308
            12.92 * c
          else
            1.055 * (c**(1.0 / 2.4)) - 0.055
          end
      (c * 255.0).round.clamp(0, 255)
    end

    # Oklab → sRGB [r, g, b] (0..255)
    def oklab_to_srgb8(l, a, b)
      r, g, b_ = oklab_to_linear_rgb(l, a, b)
      [linear_to_srgb(r), linear_to_srgb(g), linear_to_srgb(b_)]
    end
  end
end
