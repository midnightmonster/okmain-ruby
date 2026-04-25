# frozen_string_literal: true

module Okmain
  # Xoshiro256++ PRNG, matching Rust's rand_xoshiro crate exactly.
  # Seeding via SplitMix64 matches Rust's SeedableRng::seed_from_u64.
  class Xoshiro256PlusPlus
    MASK64 = (1 << 64) - 1

    def initialize(seed)
      # SplitMix64 seeding (matches Rust's SeedableRng::seed_from_u64)
      sm = seed & MASK64
      @s = Array.new(4) do
        sm = (sm + 0x9e3779b97f4a7c15) & MASK64
        z = sm
        z = ((z ^ (z >> 30)) * 0xbf58476d1ce4e5b9) & MASK64
        z = ((z ^ (z >> 27)) * 0x94d049bb133111eb) & MASK64
        z ^ (z >> 31)
      end
    end

    # Generate next u64
    def next_u64
      s = @s
      result = (rotl(s[0] + s[3], 23) + s[0]) & MASK64
      t = (s[1] << 17) & MASK64
      s[2] ^= s[0]
      s[3] ^= s[1]
      s[1] ^= s[2]
      s[0] ^= s[3]
      s[2] ^= t
      s[3] = rotl(s[3], 45)
      result
    end

    # Uniform integer in 0...range, using Lemire's method (matching Rust's rand crate)
    def random_range(range)
      full = next_u64 * range
      hi = full >> 64
      lo = full & MASK64
      if lo < range
        threshold = (MASK64 - range + 1) % range # (2^64 - range) % range
        while lo < threshold
          full = next_u64 * range
          hi = full >> 64
          lo = full & MASK64
        end
      end
      hi
    end

    # Uniform f32 in [0, 1), matching Rust's rand StandardUniform for f32.
    # Xoshiro256++.next_u32() returns next_u64() >> 32 (upper bits).
    # Then StandardUniform takes top 24 bits of the u32.
    def random_f32
      u64 = next_u64
      u32 = u64 >> 32        # Rust's next_u32() for Xoshiro256++
      (u32 >> 8).to_f / 16777216.0 # top 24 bits / 2^24
    end

    private

    def rotl(x, k)
      ((x << k) | (x >> (64 - k))) & MASK64
    end
  end
end
