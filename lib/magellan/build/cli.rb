require "magellan/build"

require 'thor'

module Magellan
  module Build
    class Cli < Thor

      desc "init", "initialize current directory"
      def init
        VersionFile.new.init
      end

      desc "bump", "bump up 3rd number in VERSION"
      def bump
        VersionFile.new.bump
      end

      desc "build", "build docker image"
      def build
        Docker.new.build
      end

      desc "release", "build docker image, tag it, push tag and push docker image to docker hub"
      def release
        Docker.new.build
        Git.new.guard_clean
        Git.new.push
        Docker.new.push
      end

      desc "version SUBCOMMAND ...ARGS", "manage VERSION file"
      subcommand "version", VersionFile

      desc "docker SUBCOMMAND ...ARGS", "manage docker"
      subcommand "docker", Docker

      desc "git SUBCOMMAND ...ARGS", "manage git commit"
      subcommand "git", Git

    end
  end
end
