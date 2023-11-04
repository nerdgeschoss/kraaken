# frozen_string_literal: true

require "net/ssh"

class Kraaken::Ssh
  def initialize(config:)
    @config = config
  end

  def regenerate_config
    servers = config.cloud.servers
    jump = servers.find(&:jump?)
    servers.reject!(&:jump?)
    config = <<~SSH
      Host jump
      User root
      HostName #{jump.public_ip}
      ForwardAgent yes
    SSH
    servers.each do |server|
      config += <<~SSH

        Host #{server.name}
        User nerd
        HostName #{server.ip}
        ProxyJump jump
      SSH
    end
    File.write(File.join(Dir.home, ".ssh", "cloud_config"), config)
    config_path = File.join(Dir.home, ".ssh", "config")
    unless File.read(config_path).include?("Include cloud_config")
      File.write(config_path, "Include cloud_config\n\n" + File.read(config_path))
    end
  end

  def connect(name)
    Net::SSH.start(name) do |ssh|
      yield Kraaken::Ssh::Connection.new(ssh, logger: config.logger) if block_given?
    end
  end

  private

  attr_reader :config
end
