# frozen_string_literal: true

require "hcloud"

class Kraaken::Cloud::Hetzner < Kraaken::Cloud
  def provision(name, groups:)
    keys = client.ssh_keys
    user_data = config.load_template("cloud_config.yml", keys:)
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
    action, server = cloud.servers.create(options)
    await_action action
    server = await_startup server
    config.ssh.regenerate_config
    sleep 10
    await_action server.reboot
    prepare name
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
      server = cloud.servers.find(server.id)
    end
    server
  end
end
