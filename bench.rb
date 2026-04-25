# frozen_string_literal: true

require "benchmark"
require "objspace"
require_relative "lib/okmain"

IMAGE = ARGV[0] || Dir["tmp/*.png"].first
abort "Usage: ruby bench.rb <image_path>" unless IMAGE && File.exist?(IMAGE)

img = Vips::Image.new_from_file(IMAGE)
puts "Image: #{File.basename(IMAGE)} (#{img.width}x#{img.height}, #{img.width * img.height} px)"
puts

config = Okmain::Config.new

# Warm up (load vips, JIT, etc.)
Okmain.colors(IMAGE)

# --- Timing per phase ---
puts "=== Phase timing (5 runs) ==="
5.times do |run|
  GC.start
  GC.compact

  times = {}

  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  pixels, w, h = Okmain::Sampler.sample(IMAGE)
  times[:sample] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  mask = Okmain::DistanceMask.compute(w, h)
  times[:mask] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  centroids, assignments = Okmain::KMeans.cluster(pixels)
  times[:kmeans] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = Okmain::Scorer.score(centroids, assignments, mask, config)
  times[:score] = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0

  total = times.values.sum
  parts = times.map { |k, v| "#{k}=#{(v * 1000).round(1)}ms" }.join(", ")
  puts "  Run #{run + 1}: #{(total * 1000).round(1)}ms total (#{parts})"
end

# --- Memory ---
puts
puts "=== Memory snapshot ==="
GC.start
GC.compact

before_mem = `ps -o rss= -p #{$$}`.strip.to_i # KB
before_objects = ObjectSpace.count_objects

pixels, w, h = Okmain::Sampler.sample(IMAGE)
after_sample_mem = `ps -o rss= -p #{$$}`.strip.to_i

mask = Okmain::DistanceMask.compute(w, h)
after_mask_mem = `ps -o rss= -p #{$$}`.strip.to_i

centroids, assignments = Okmain::KMeans.cluster(pixels)
after_kmeans_mem = `ps -o rss= -p #{$$}`.strip.to_i

after_objects = ObjectSpace.count_objects

puts "  Sampled grid: #{w}x#{h} = #{pixels.size} pixels"
puts "  RSS growth: sample=+#{after_sample_mem - before_mem}KB, mask=+#{after_mask_mem - after_sample_mem}KB, kmeans=+#{after_kmeans_mem - after_mask_mem}KB"
puts "  Object delta: #{(after_objects[:TOTAL] - before_objects[:TOTAL]).abs} objects"
puts "  RSS total: #{after_kmeans_mem}KB"

# --- GC allocation tracing (single run) ---
puts
puts "=== GC allocations (single run) ==="
GC.start
before_gc = GC.stat[:total_allocated_objects]
Okmain.colors(IMAGE)
after_gc = GC.stat[:total_allocated_objects]
puts "  Total objects allocated: #{after_gc - before_gc}"

# --- Comparison with Rust ---
rust_bin = File.expand_path("rust_compare/target/release/rust_compare", __dir__)
if File.exist?(rust_bin)
  puts
  puts "=== Rust comparison ==="
  5.times do |run|
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    `#{rust_bin} #{IMAGE}`
    t = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
    puts "  Run #{run + 1}: #{(t * 1000).round(1)}ms"
  end
end
