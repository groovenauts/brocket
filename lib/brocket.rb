require "magellan/build/version"

module Magellan
  module Build
    autoload :Cli        ,    "magellan/build/cli"
    autoload :Base       ,    "magellan/build/base"
    autoload :VersionFile,    "magellan/build/version_file"
    autoload :Git        ,    "magellan/build/git"
    autoload :Docker     ,    "magellan/build/docker"

    class BuildError < StandardError
    end
  end
end
