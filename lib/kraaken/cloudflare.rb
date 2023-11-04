# frozen_string_literal: true

require "faraday"

class Kraaken::Cloudflare
  Tunnel = Struct.new(:id, :name, :status, :cloudflare, :_token) do
    def token
      _token || cloudflare.tunnel_token(id:)
    end
  end

  def initialize(config:)
    @config = config
  end

  def tunnels
    client.get("/client/v4/accounts/#{credential.username}/cfd_tunnel").body["result"]&.map do |tunnel|
      Tunnel.new(tunnel["id"], tunnel["name"], tunnel["status"], self)
    end || raise("Could not fetch tunnels")
  end

  def create_tunnel(name)
    tunnel_secret = Base64.strict_encode64 SecureRandom.hex(32)
    body = {name:, tunnel_secret:, config_src: "cloudflare"}
    config = {
      config: {
        ingress: [
          {
            hostname: "#{name}.server.nerdgeschoss.de",
            service: "http://traefik:8080"
          },
          {
            hostname: "*.#{name}.nerdgeschoss.de",
            service: "http://traefik"
          },
          {
            service: "http_status:404"
          }
        ]
      }
    }
    res = client.post("/client/v4/accounts/#{credential.username}/cfd_tunnel", body).body["result"]
    tunnel = Tunnel.new(res["id"], res["name"], res["status"], self, res["token"])
    logger.info "Creating tunnel #{name} with id #{tunnel.id}"
    client.put("/client/v4/accounts/#{credential.username}/cfd_tunnel/#{tunnel.id}/configurations", config)
    server_dns = {
      type: "CNAME",
      proxied: true,
      name: "#{name}.server.nerdgeschoss.de",
      content: "#{tunnel.id}.cfargotunnel.com"
    }
    logger.info "Creating DNS record for #{name}.server.nerdgeschoss.de"
    client.post("/client/v4/zones/#{zone_id}/dns_records", server_dns)
    app_dns = {
      type: "CNAME",
      proxied: true,
      name: "*.#{name}.nerdgeschoss.de",
      content: "#{tunnel.id}.cfargotunnel.com"
    }
    logger.info "Creating DNS record for #{name}.server.nerdgeschoss.de"
    client.post("/client/v4/zones/#{zone_id}/dns_records", app_dns)
    logger.info "Tunnel #{name} created"
    tunnel
  end

  def tunnel_token(id:)
    client.get("/client/v4/accounts/#{credential.username}/cfd_tunnel/#{id}/token").body["result"] || raise("Could not fetch tunnel token")
  end

  def tunnel_token_for_name(name)
    (tunnels.find { _1.name == name } || create_tunnel(name)).token
  end

  private

  attr_reader :config

  delegate :logger, to: :config

  def client
    @client ||= Faraday.new(url: "https://api.cloudflare.com") do |f|
      f.request :authorization, "Bearer", credential.password
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end

  def credential
    @credential ||= config.credentials.credential("cloudflare")
  end

  def zone_id
    config.credentials.password("cloudflare-zone")
  end
end
