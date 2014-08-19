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

      desc "major [NUMBER]", "bump up major version of VERSION file"
      def major(num = nil)
        bump_on(0, num)
      end

      desc "minor [NUMBER]", "bump up minor version of VERSION file"
      def minor(num = nil)
        bump_on(1, num)
      end

      desc "bump [NUMBER]", "bump up last number of VERSION file"
      def bump(num = nil)
        bump_on(2, num)
      end

      def read_file
        File.read(FILENAME).strip
      end
      private :read_file

      def write_file(version)
        File.open(FILENAME, "w"){|f| f.puts(version) }
      end
      private :write_file

      def bump_on(pos, num)
        current = read_file
        body, suffix = current.split(/-/, 2)
        parts = body.split(/\./)
        parts[pos] = num || (parts[pos].to_i + 1).to_s
        ver = parts.join(".")
        ver << "-" << suffix if suffix
        write_file(ver)
        ver
      end
      private :bump_on

    end
  end
end
