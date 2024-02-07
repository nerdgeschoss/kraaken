# frozen_string_literal: true

require "hcloud"

class Kraaken::Cloud::Hetzner < Kraaken::Cloud
  def provision(name, groups:)
    logger.with_progress(total: 100) do
      logger.info "Provisioning server #{name}"
      keys = client.ssh_keys
      user_data = config.load_template("cloud-config.yml", keys:)
      options = {
        name:,
        server_type: "cax41",
        image: "ubuntu-22.04",
        labels: {group: groups.join(".")},
        location: "nbg1",
        networks: [client.networks.first.id],
        ssh_keys: keys.map(&:id),
        user_data:
      }
      logger.increment_progress by: 5
      logger.info "Creating server"
      action, server = client.servers.create(**options)
      await_action action
      logger.increment_progress by: 10
      server = await_startup server
      logger.info "Server started #{server.public_net.dig("ipv4", "ip")}"
      logger.increment_progress by: 10
      logger.info "Regenrating ssh config"
      config.ssh.regenerate_config
      logger.increment_progress by: 5
      sleep 10
      logger.increment_progress by: 10
      logger.info "Rebooting server after applying cloud-config"
      await_action server.reboot
      logger.increment_progress by: 10
      prepare name
      servers.find { _1.name == name }
    end
  end

  def servers
    client.servers.map { Kraaken::Cloud::Server.new(name: _1.name, ip: _1.private_net.first&.ip, public_ip: _1.public_net.dig("ipv4", "ip"), status: _1.status) }
  end

  private

  def client
    @client ||= Hcloud::Client.new(token: config.credentials.password("hetzner"))
  end

  def await_action(action)
    while action.status == "running"
      sleep 2
      action = client.actions.find(action.id)
    end
  end

  def await_startup(server)
    while server.status == "initializing" || server.status == "starting" || server.status == "off"
      sleep 3
      server = client.servers.find(server.id)
    end
    server
  end
end
