require "brocket"

module BRocket
  class VersionFile < Base
    FILENAME = "VERSION".freeze
    INITIAL_VERSION = "0.0.1".freeze

    desc "init [VERSION]", "initialize VERSION file in current directory"
    def init(version = nil)
      write_file(version || INITIAL_VERSION)
    end

    desc "show", "show VERSION"
    def show
      $stdout.puts(read_file)
    end

    desc "major [NUMBER]", "bump up major version of VERSION file"
    def major(num = nil)
      bump_on(:major, num)
    end

    desc "minor [NUMBER]", "bump up minor version of VERSION file"
    def minor(num = nil)
      bump_on(:minor, num)
    end

    desc "bump [NUMBER]", "bump up last number of VERSION file"
    def bump(num = nil)
      bump_on(:patch, num)
    end

    class << self
      def current
        if File.readable?(FILENAME)
          File.read(FILENAME).strip
        else
          error "File not found #{FILENAME}. You can run `#{$0} init`"
        end
      end
    end

    no_commands do
      def read_file
        self.class.current
      end
      private :read_file

      def write_file(version)
        File.open(FILENAME, "w"){|f| f.puts(version) }
      end
      private :write_file

      POS_TO_IDX = {major: 0, minor: 1, patch: 2}.freeze

      def bump_on(pos, num)
        sub(Git).guard_clean
        current = read_file
        body, suffix = current.split(/-/, 2)
        parts = body.split(/\./)
        idx = POS_TO_IDX[pos]
        error "Invalid position #{pos.inspect}" unless idx
        parts[idx] = num || (parts[idx].to_i + 1).to_s
        ver = parts.join(".")
        ver << "-" << suffix if suffix
        write_file(ver)
        sub(Git).commit(FILENAME, "bump up #{pos.to_s} version: #{ver}")
        success("[git #{pos.to_s}] #{ver}")
        ver
      end
      private :bump_on
    end

  end
end
