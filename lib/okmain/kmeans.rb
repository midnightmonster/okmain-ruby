# frozen_string_literal: true

module Okmain
  module KMeans
    MAX_CENTROIDS = 4
    LLOYDS_MAX_ITERATIONS = 300
    LLOYDS_CONVERGENCE_TOL = 1e-3
    SIMILAR_CLUSTER_DISTANCE_SQ = 0.005
    KMEANSPP_CANDIDATES = 3
    RANDOM_SEED = 314159

    module_function

    # Returns [centroids, assignments] where centroids is Array of [L, a, b]
    # and assignments is Array of centroid indices per pixel.
    def cluster(pixels, k: MAX_CENTROIDS)
      rng = Xoshiro256PlusPlus.new(RANDOM_SEED)
      n = pixels.size
      return [pixels.dup, Array.new(n) { |i| i }] if n <= k

      loop do
        centroids = init_plusplus(pixels, k, rng)
        assignments = Array.new(n, 0)

        centroids, assignments = lloyds(pixels, centroids, assignments, k, rng)

        # Adaptive reduction: merge similar centroids
        merged = false
        i = 0
        while i < k - 1 && !merged
          j = i + 1
          while j < k && !merged
            if distance_sq(centroids[i], centroids[j]) < SIMILAR_CLUSTER_DISTANCE_SQ
              k -= 1
              merged = true
            end
            j += 1
          end
          i += 1
        end

        return [centroids, assignments] unless merged
      end
    end

    # K-means++ initialization with 3 candidates per step
    def init_plusplus(pixels, k, rng)
      n = pixels.size
      centroids = [pixels[rng.random_range(n)].dup]

      dist_sq = Array.new(n, Float::INFINITY)

      (1...k).each do
        # Update distances to nearest centroid
        last = centroids.last
        i = 0
        while i < n
          d = distance_sq(pixels[i], last)
          dist_sq[i] = d if d < dist_sq[i]
          i += 1
        end

        total = dist_sq.sum
        best_candidate = nil
        best_potential = Float::INFINITY

        KMEANSPP_CANDIDATES.times do
          # Weighted random selection (matching Rust's sample_by_distance)
          r = rng.random_f32 * total
          cumulative = 0.0
          idx = 0
          while idx < n
            cumulative += dist_sq[idx]
            if cumulative > r
              break
            end
            idx += 1
          end
          idx = n - 1 if idx >= n

          # Compute potential for this candidate
          candidate = pixels[idx]
          potential = 0.0
          i = 0
          while i < n
            d = distance_sq(pixels[i], candidate)
            potential += d < dist_sq[i] ? d : dist_sq[i]
            i += 1
          end

          if potential < best_potential
            best_potential = potential
            best_candidate = candidate
          end
        end

        centroids << best_candidate.dup
      end

      centroids
    end

    def lloyds(pixels, centroids, assignments, k, rng)
      n = pixels.size

      LLOYDS_MAX_ITERATIONS.times do
        # Assignment step
        i = 0
        while i < n
          px = pixels[i]
          best = 0
          best_d = distance_sq(px, centroids[0])
          c = 1
          while c < k
            d = distance_sq(px, centroids[c])
            if d < best_d
              best_d = d
              best = c
            end
            c += 1
          end
          assignments[i] = best
          i += 1
        end

        # Update step
        new_centroids = Array.new(k) { [0.0, 0.0, 0.0] }
        counts = Array.new(k, 0)

        i = 0
        while i < n
          c = assignments[i]
          px = pixels[i]
          nc = new_centroids[c]
          nc[0] += px[0]
          nc[1] += px[1]
          nc[2] += px[2]
          counts[c] += 1
          i += 1
        end

        shift_sq = 0.0
        c = 0
        while c < k
          if counts[c] == 0
            # Reassign empty cluster to random data point
            ri = rng.random_range(n)
            new_centroids[c] = pixels[ri].dup
          else
            inv = 1.0 / counts[c]
            nc = new_centroids[c]
            nc[0] *= inv
            nc[1] *= inv
            nc[2] *= inv
          end
          dl = new_centroids[c][0] - centroids[c][0]
          da = new_centroids[c][1] - centroids[c][1]
          db = new_centroids[c][2] - centroids[c][2]
          shift_sq += dl * dl + da * da + db * db
          c += 1
        end

        centroids = new_centroids
        break if shift_sq < LLOYDS_CONVERGENCE_TOL
      end

      [centroids, assignments]
    end

    def distance_sq(a, b)
      dl = a[0] - b[0]
      da = a[1] - b[1]
      db = a[2] - b[2]
      dl * dl + da * da + db * db
    end
  end
end
