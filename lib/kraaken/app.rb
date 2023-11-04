# frozen_string_literal: true

class Kraaken::App
  attr_reader :name, :server, :destination

  def initialize(name:, destination:, server:, config:)
    @name = name
    @destination = destination
    @server = server
    @config = config
  end

  def environment
    create
    ssh.connect(server) do |ssh|
      ssh.read_file("~/#{full_name}/.env")
    end
  end

  def environment=(content)
    ssh.connect(server) do |ssh|
      ssh.write_file("~/#{full_name}/.env", content)
    end
  end

  def create
    ssh.connect(server) do |ssh|
      ssh.run("mkdir -p ~/#{full_name}")
      ssh.run("touch ~/#{full_name}/.env")
    end
  end

  def deploy(file)
    ssh.connect(server) do |ssh|
      ssh.run <<~BASH
        mkdir -p ~/#{full_name}
        cd ~/#{full_name}
        touch .env
      BASH
      ssh.write_file("~/#{full_name}/docker-compose.yml", config.load_template(file.path, app: self))
      ssh.run <<~BASH
        cd ~/#{full_name}
        docker-compose pull
        docker-compose up -d
      BASH
    end
  end

  def destroy
    ssh.connect(server) do |ssh|
      ssh.run("cd ~/#{full_name} && docker-compose down --volumes --remove-orphans")
      ssh.run("rm -rf ~/#{full_name}")
    end
  end

  def logs
    ssh.connect(server) do |ssh|
      ssh.run("cd ~/#{full_name} && docker-compose logs -f")
    end
  end

  def full_name
    "#{name}-#{destination}"
  end

  private

  attr_reader :config

  delegate :ssh, to: :config
end
