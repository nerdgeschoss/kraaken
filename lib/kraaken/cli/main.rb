# frozen_string_literal: true

class Kraaken::Cli::Main < Kraaken::Cli::Base
  desc "server", "Provision and manage servers"
  subcommand "server", Kraaken::Cli::Server

  desc "ssh", "Manage ssh connections and keys"
  subcommand "ssh", Kraaken::Cli::Ssh

  desc "app", "Manage apps"
  subcommand "app", Kraaken::Cli::App
end
