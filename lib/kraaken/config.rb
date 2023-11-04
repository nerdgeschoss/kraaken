# frozen_string_literal: true

class Kraaken::Config
  def credentials
    @credentials ||= Kraaken::Credentials::OnePassword.new
  end

  def cloud
    @cloud ||= Kraaken::Cloud::Hetzner.new(config: self)
  end

  def ssh
    @ssh ||= Kraaken::Ssh.new(config: self)
  end

  def ingress
    @ingress ||= Kraaken::Cloudflare.new(config: self)
  end

  def logger
    @logger ||= Kraaken::Logger.new
  end

  def load_template(name, **locals)
    locals[:config] = self
    name = File.expand_path("../config/#{name}", __dir__) unless name.start_with?("/")
    ERB.new(File.read(name)).result_with_hash(locals)
  end
end
