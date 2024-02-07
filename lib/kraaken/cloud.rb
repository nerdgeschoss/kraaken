# frozen_string_literal: true

class Kraaken::Cloud
  Server = Struct.new(:name, :ip, :public_ip, :status) do
    def jump?
      name == "jump"
    end
  end

  def initialize(config:)
    @config = config
  end

  def provision(name)
    raise NotImplementedError
  end

  def prepare(name)
    new_relic = config.credentials.credential("new-relic")
    config.ssh.connect(name) do |ssh|
      ssh.run <<~BASH
        sudo apt update
        sudo apt upgrade -y
        sudo apt install -y docker.io docker-compose
        sudo docker network create ingress
        sudo gpasswd -a $USER docker
        curl -Ls https://download.newrelic.com/install/newrelic-cli/scripts/install.sh | bash && sudo NEW_RELIC_API_KEY=#{new_relic.password} NEW_RELIC_ACCOUNT_ID=#{new_relic.username} NEW_RELIC_REGION=EU /usr/local/bin/newrelic install -y
      BASH
    end
    logger.increment_progress by: 25
    config.ssh.connect(name) do |ssh|
      ssh.run "mkdir -p ~/traefik"
      ssh.write_file "~/traefik/docker-compose.yml", config.load_template("traefik-compose.yml", name:)
      logger.increment_progress by: 20
      ssh.run "cd ~/traefik && docker-compose up -d"
      ssh.run "echo #{config.credentials.password("docker-registry")} | docker login ghcr.io -u USERNAME --password-stdin", log: false
    end
  end

  def servers
    raise NotImplementedError
  end

  protected

  attr_reader :config
  delegate :logger, to: :config
end
