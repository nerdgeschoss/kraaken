# frozen_string_literal: true

class Kraaken::Ssh::Connection
  def initialize(ssh, logger:)
    @logger = logger
    @ssh = ssh
  end

  def run(positional_script = nil, log: true, script: nil)
    script ||= positional_script
    output = []
    logger.info script if log
    ssh.exec!(script) do |channel, stream, data|
      logger.debug data if log
      output << data
    rescue Encoding::UndefinedConversionError
    end
    output.join("\n")
  end

  def write_file(path, content)
    run log: false, script: <<~BASH
      cat <<'EOT' >> #{path}
      #{content}
      EOT
    BASH
  end

  private

  attr_reader :ssh, :logger
end
