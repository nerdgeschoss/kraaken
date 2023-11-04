# frozen_string_literal: true

class Kraaken::Cli::Base < Thor
  def self.exit_on_failure?
    true
  end

  protected

  def config
    @config ||= Kraaken::Config.new
  end
end
