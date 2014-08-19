require "magellan/build"

require 'thor'

module Magellan
  module Build
    class VersionFile < Thor
      FILENAME = "VERSION".freeze

      desc "init", "initialize VERSION file in current directory"
      def init
        File.open(FILENAME, "w"){|f| f.puts("0.0.1") }
      end
    end
  end
end
