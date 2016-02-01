require "brocket/version"

require 'logger'

module BRocket
  autoload :Cli        ,    "brocket/cli"
  autoload :Base       ,    "brocket/base"
  autoload :Configurable,   "brocket/configurable"
  autoload :VersionFile,    "brocket/version_file"
  autoload :Git        ,    "brocket/git"
  autoload :Docker     ,    "brocket/docker"

  class BuildError < StandardError
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stderr)
    end
  end
end
