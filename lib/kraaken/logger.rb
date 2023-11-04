# frozen_string_literal: true

require "ruby-progressbar"

class Kraaken::Logger < ActiveSupport::Logger
  def initialize
    super Kraaken::Logger::LogDevice.new(-> { @progress_bar })
    @painter = Kraaken::Logger::Color.new
    self.formatter = Kraaken::Logger::Formatter.new(@painter)
  end

  def with_progress(total:, title: nil, &block)
    @progress_bar = ProgressBar.create(
      total:,
      title:,
      format: "%t |#{color("%B", color: :blue)}|"
    )

    block.call

    @progress_bar.finish
    @progress_bar = nil
  end

  def increment_progress(by: 1)
    @progress_bar&.progress += by
  end

  delegate :color, to: :@painter
end
