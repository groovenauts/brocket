require "magellan/build"

module Magellan
  module Build
    class Cli < Base

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

      desc "release [DIRECTORY]", "build docker image, tag it, push tag and push docker image to docker hub"
      def release(dir = nil)
        Docker.new.build(dir)
        Git.new.guard_clean
        Git.new.push
        Docker.new.push(dir)
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
