# frozen_string_literal: true

class Kraaken::Cli::Server < Kraaken::Cli::Base
  desc "provision NAME", "Provision a new server"
  method_option :group, aliases: "-g", desc: "assign the server to an access group, default: admin"
  def provision(name)
    groups = [options[:group] || "admin", "admin"].uniq
    server = config.cloud.provision(name, groups:)
    config.cloudflare.create_dns(name: server.name, ip: server.public_ip)
  end

  desc "list", "Lists all current servers"
  def list
    config.cloud.servers.each do |server|
      logger.info "#{server.name} (#{server.status}) #{server.ip} #{server.public_ip}"
    end
  end
end
