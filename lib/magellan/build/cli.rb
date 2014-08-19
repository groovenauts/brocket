require "magellan/build"

require 'thor'

module Magellan
  module Build
    class Cli < Thor

      desc "init", "initialize current directory"
      def init
        VersionFile.new.init
      end

      desc "version SUBCOMMAND ...ARGS", "manage VERSION file"
      subcommand "version", VersionFile

      # desc "git SUBCOMMAND ...ARGS", "manage git commit"
      # subcommand "git", Git

      # desc "docker SUBCOMMAND ...ARGS", "manage docker"
      # subcommand "docker", Docker

    end
  end
end
