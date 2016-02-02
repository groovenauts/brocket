require "brocket"

module BRocket
  class VersionFile < Configurable
    FILENAME = "VERSION".freeze
    INITIAL_VERSION = "0.0.1".freeze

    desc "init [VERSION]", "initialize VERSION file in directory for docker"
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

    no_commands do
      def filepath
        File.expand_path(config_hash['VERSION_FILE'] || 'VERSION', File.dirname(config_filepath))
      end

      def read_file
        vs = config_hash['VERSION_SCRIPT']
        if vs
          Dir.chdir(File.dirname(config_filepath)) do
            res = `#{vs}`.strip
            return $? == 0 ? res : error("Error on VERSION_SCRIPT: #{vs}")
          end
        else
          if File.readable?(filepath)
            File.read(filepath).strip
          else
            error "File not found #{filepath}. You can run `#{$0} init`"
          end
        end
      end
      alias_method :current, :read_file

      def write_file(version)
        File.open(filepath, "w"){|f| f.puts(version) }
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
        sub(Git).add_and_commit(filepath, "bump up #{pos.to_s} version: #{ver}")
        success("[git #{pos.to_s}] #{ver}")
        ver
      end
      private :bump_on
    end

  end
end
