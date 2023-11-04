# frozen_string_literal: true

class Kraaken::Cli::Ssh < Kraaken::Cli::Base
  desc "config", "updates the local ssh config file"
  def config
    super.ssh.regenerate_config
  end
end
