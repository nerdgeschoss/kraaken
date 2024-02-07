# frozen_string_literal: true

require "faraday"

class Kraaken::Cloudflare
  def initialize(config:)
    @config = config
  end

  def create_dns(name:, ip:)
    server_dns = {
      type: "A",
      proxied: true,
      name: "#{name}.server.nerdgeschoss.de",
      content: ip
    }
    logger.info "Creating DNS record for #{name}.server.nerdgeschoss.de"
    client.post("/client/v4/zones/#{zone_id}/dns_records", server_dns)
    app_dns = {
      type: "A",
      proxied: true,
      name: "*.#{name}.nerdgeschoss.de",
      content: ip
    }
    logger.info "Creating DNS record for *.#{name}.nerdgeschoss.de"
    client.post("/client/v4/zones/#{zone_id}/dns_records", app_dns)
  rescue Faraday::BadRequestError => e
    puts e.response[:body]
    raise e
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
