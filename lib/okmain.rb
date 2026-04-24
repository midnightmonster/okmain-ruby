# frozen_string_literal: true

require_relative "okmain/version"
require_relative "okmain/config"
require_relative "okmain/oklab"
require_relative "okmain/sampler"
require_relative "okmain/distance_mask"
require_relative "okmain/kmeans"
require_relative "okmain/scorer"

module Okmain
  module_function

  # Extract up to 4 dominant colors from an image.
  #
  # @param input [String, Vips::Image] file path or preloaded vips image
  # @param config [Okmain::Config] optional scoring config
  # @return [Array<Array<Integer>>] up to 4 [r, g, b] arrays sorted by score
  def colors(input, config: Config.new)
    pixels, width, height = Sampler.sample(input)
    mask = DistanceMask.compute(width, height)
    centroids, assignments = KMeans.cluster(pixels)
    Scorer.score(centroids, assignments, mask, config)
  end
end
