require "magellan/build"

require 'yaml'
require 'thor'

require 'fileutils'

module Magellan
  module Build
    class Docker < Base
      MGB_LINE_HEADER = /\A\#\s*\[MGB\]\s*/.freeze

      desc "config [DIRECTORY]", "show configurations in Dockerfile"
      def config(dir = nil)
        fileutils.chdir(dir || ".") do
          content = read_file
          lines = content.lines.select{|line| line =~ MGB_LINE_HEADER}.
            map{|line| line.sub(MGB_LINE_HEADER, "")}
          r = YAML.load(lines.join("\n"))
          $stdout.puts(YAML.dump(r))
          return r
        end
      end

      desc "build [DIRECTORY]", "build docker image at DIRECTORY or PWD"
      def build(dir = nil)
        c = config(dir)
        fileutils.chdir(dir || ".") do
          cmd = "docker build -t #{c['IMAGE_NAME']}:#{VersionFile.current} ."
          execute_command(cmd)
        end
      end

      no_commands do
        def read_file
          File.read("Dockerfile")
        end

        def execute_command(cmd)
          # http://docs.ruby-lang.org/ja/2.0.0/class/Kernel.html#M_SYSTEM
          exit($?) unless system(cmd)
        end
      end

    end
  end
end
