require "brocket/version"

module BRocket
  module Build
    autoload :Cli        ,    "brocket/cli"
    autoload :Base       ,    "brocket/base"
    autoload :VersionFile,    "brocket/version_file"
    autoload :Git        ,    "brocket/git"
    autoload :Docker     ,    "brocket/docker"

    class BuildError < StandardError
    end
  end
end
