require "brocket"

module BRocket
  class Cli < Base

    desc "init", "initialize current directory"
    def init
      sub(VersionFile).init
    end

    desc "bump", "bump up 3rd number in VERSION"
    def bump
      sub(VersionFile).bump
    end

    desc "build", "build docker image"
    def build
      sub(Docker).build
    end

    desc "release", "build docker image, tag it, push tag and push docker image to docker hub"
    def release
      sub(Git).guard_clean
      sub(Docker).build
      sub(Git).push
      sub(Docker).push
    end

    desc "version SUBCOMMAND ...ARGS", "manage VERSION file"
    subcommand "version", VersionFile

    desc "docker SUBCOMMAND ...ARGS", "manage docker"
    subcommand "docker", Docker

    desc "git SUBCOMMAND ...ARGS", "manage git commit"
    subcommand "git", Git

  end
end
