# frozen_string_literal: true

module Kraaken
  class Error < StandardError; end
  # Your code goes here...
end

require "active_support"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/kamal/sshkit_with_ext.rb")
loader.setup
loader.eager_load
