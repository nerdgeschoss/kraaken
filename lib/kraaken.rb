# frozen_string_literal: true

module Kraaken
  class Error < StandardError; end
end

require "active_support"
require "active_support/core_ext"
require "zeitwerk"
require "thor"
require "open3"
require "tempfile"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
