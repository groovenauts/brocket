require "magellan/build"

require 'yaml'
require 'thor'

require 'fileutils'

module Magellan
  module Build
    class Docker < Base
      CONFIG_LINE_SEP = "[config]".freeze

      CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s*/.freeze

      desc "config [DIRECTORY]", "show configurations in Dockerfile"
      def config(dir = nil)
        $stdout.puts(YAML.dump(config_hash(dir)))
      end

      desc "build [DIRECTORY]", "build docker image at DIRECTORY or PWD"
      def build(dir = nil)
        dir ||= "."
        c = config_hash(dir)
        img_name = (c['IMAGE_NAME'] || '').strip
        raise "No IMAGE_NAME found in #{dir}/Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in #{dir}/Dockerfile" if img_name.empty?
        fileutils.chdir(dir) do
          cmd = "docker build -t #{img_name}:#{VersionFile.current} ."
          setup = (c['SETUP'] || '').strip
          cmd = "#{setup} && #{cmd}" unless setup.empty?
          sh(cmd)
        end
      end

      desc "push [DIRECTORY]", "push docker image to docker hub"
      def push(dir = nil)
        dir ||= "."
        c = config_hash(dir)
        img_name = (c['IMAGE_NAME'] || '').strip
        raise "No IMAGE_NAME found in #{dir}/Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in #{dir}/Dockerfile" if img_name.empty?
        cmd = "docker push #{img_name}:#{VersionFile.current}"
        sh(cmd)
      end

      no_commands do
        def config_hash(dir = nil)
          dir ||= "."
          fileutils.chdir(dir) do
            content = read_file
            lines = content.lines.select{|line| line =~ CONFIG_LINE_HEADER}.
              map{|line| line.sub(CONFIG_LINE_HEADER, "")}
            return (YAML.load(lines.join("\n")) || {})
          end
        end

        def read_file
          File.read("Dockerfile")
        end
      end

    end
  end
end
