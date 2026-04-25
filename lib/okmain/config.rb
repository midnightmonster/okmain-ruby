# frozen_string_literal: true

module Okmain
  class Config
    attr_reader :chroma_weight, :mask_weighted_counts_weight,
                :mask_weight, :mask_saturated_threshold

    def initialize(
      chroma_weight: 0.7,
      mask_weighted_counts_weight: 0.3,
      mask_weight: 1.0,
      mask_saturated_threshold: 0.3
    )
      raise ArgumentError, "chroma_weight must be between 0 and 1" unless (0.0..1.0).cover?(chroma_weight)
      raise ArgumentError, "mask_weighted_counts_weight must be between 0 and 1" unless (0.0..1.0).cover?(mask_weighted_counts_weight)
      raise ArgumentError, "mask_weight must be between 0 and 1" unless (0.0..1.0).cover?(mask_weight)
      raise ArgumentError, "mask_saturated_threshold must be between 0 and 0.5 (exclusive)" unless mask_saturated_threshold >= 0.0 && mask_saturated_threshold < 0.5

      @chroma_weight = chroma_weight.to_f
      @mask_weighted_counts_weight = mask_weighted_counts_weight.to_f
      @mask_weight = mask_weight.to_f
      @mask_saturated_threshold = mask_saturated_threshold.to_f
    end
  end
end
