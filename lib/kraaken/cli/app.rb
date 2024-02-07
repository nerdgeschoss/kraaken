# frozen_string_literal: true

class Kraaken::Cli::App < Kraaken::Cli::Base
  include Thor::Actions

  class_option :server, aliases: "-s", desc: "server to run the command on", default: "app-1"
  class_option :app, aliases: "-a", desc: "app to run the command on"
  class_option :destination, aliases: "-d", desc: "destination environment", default: "production"

  desc "credentials", "opens the credentials file"
  def credentials
    old_content = new_content = app.environment.strip
    Tempfile.create(app.name) do |file|
      file.write old_content
      file.flush
      logger.info "Opening #{file.path}"
      run "code --wait #{file.path}"
      file.rewind
      new_content = file.read.strip
    end
    if new_content != old_content
      logger.info "Updating #{app.name} credentials"
      app.environment = new_content
    end
  end

  desc "deploy", "deploys the app"
  option :file, aliases: "-f", desc: "docker-compose file to deploy"
  def deploy
    default_path = File.expand_path("config/docker-compose.yml", destination_root)
    file = File.new(options[:file]) if options[:file].present? && File.exist?(options[:file])
    file = File.new(default_path) if !file && File.exist?(default_path)
    logger.error "No docker-compose file found" and return unless file
    app.deploy(file)
  end

  desc "destroy", "destroys the app"
  def destroy
    app.destroy
  end

  desc "logs", "shows the logs of the app"
  def logs
    app.logs
  rescue IOError # prevent error when terminating the cli
  end

  desc "exec", "exec a command within the web container"
  def exec(*command)
    run "ssh #{app.server} -t 'cd ~/#{app.full_name} && docker-compose exec web #{command.join(" ")}'"
  end

  desc "console", "opens a rails console"
  def console
    exec "bundle exec rails console"
  end

  private

  def app
    @app ||= Kraaken::App.new(server: options[:server], name: options[:app].presence || File.basename(destination_root), config:, destination: options[:destination])
  end
end
