# frozen_string_literal: true

module Okmain
  module Scorer
    MAX_SRGB_OKLAB_CHROMA = 0.32

    module_function

    # Returns Array of [r, g, b] (0..255) sorted by score descending.
    def score(centroids, assignments, mask, config)
      k = centroids.size
      n = assignments.size
      mask_w = config.mask_weight
      counts_w = config.mask_weighted_counts_weight
      chroma_w = config.chroma_weight

      # Weighted counts per centroid
      weighted_counts = Array.new(k, 0.0)
      i = 0
      while i < n
        c = assignments[i]
        w = 1.0 - mask_w * (1.0 - mask[i])
        weighted_counts[c] += w
        i += 1
      end

      # Normalize to sum to 1.0
      total = weighted_counts.sum
      if total > 0
        inv = 1.0 / total
        j = 0
        while j < k
          weighted_counts[j] *= inv
          j += 1
        end
      end

      # Score each centroid
      scored = centroids.each_with_index.map do |centroid, idx|
        chroma = Math.sqrt(centroid[1] * centroid[1] + centroid[2] * centroid[2]) / MAX_SRGB_OKLAB_CHROMA
        score = counts_w * weighted_counts[idx] + chroma_w * chroma
        [score, centroid]
      end

      scored.sort_by! { |s, _| -s }
      scored.map { |_, centroid| Oklab.oklab_to_srgb8(centroid[0], centroid[1], centroid[2]) }
    end
  end
end
