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

  USER_PWD = Dir.pwd

  class << self
    attr_writer :logger
    attr_writer :user_pwd

    def logger
      @logger ||= Logger.new($stderr)
    end

    def user_pwd
      @user_pwd ||= USER_PWD
    end
  end

end
