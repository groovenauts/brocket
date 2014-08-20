require "magellan/build"

require 'yaml'
require 'thor'

module Magellan
  module Build
    class Docker < Base
      CONFIG_LINE_SEP = "[config]".freeze
      CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s?/.freeze

      desc "config [DIRECTORY]", "show configurations in Dockerfile"
      def config(dir = nil)
        $stdout.puts(YAML.dump(config_hash(dir)))
      end

      desc "build [DIRECTORY]", "build docker image at DIRECTORY or PWD"
      def build(dir = nil)
        dir ||= "."
        c = config_hash(dir)
        img_name = config_image_name(c)
        chdir(dir) do
          begin
            execute(c['BEFORE_BUILD'])
            execute("docker build -t #{img_name}:#{VersionFile.current} .")
            execute(c['ON_BUILD_COMPLETE'])
          rescue
            execute(c['ON_BUILD_ERROR'])
          ensure
            execute(c['AFTER_BUILD'])
          end
        end
      end

      desc "push [DIRECTORY]", "push docker image to docker hub"
      def push(dir = nil)
        c = config_hash(dir || ".")
        img_name = config_image_name(c)
        cmd = "docker push #{img_name}:#{VersionFile.current}"
        sh(cmd)
      end

      no_commands do
        def config_image_name(c)
          img_name = (c['IMAGE_NAME'] || '').strip
          error "No IMAGE_NAME found in #{dir}/Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in #{dir}/Dockerfile" if img_name.empty?
          img_name
        end

        def config_hash(dir = nil)
          dir ||= "."
          chdir(dir) do
            content = read_file
            lines = content.lines.select{|line| line =~ CONFIG_LINE_HEADER}.
              map{|line| line.sub(CONFIG_LINE_HEADER, "")}
            return (YAML.load(lines.join("\n")) || {})
          end
        end

        def read_file
          File.read("Dockerfile")
        end

        def execute(commands)
          return unless commands
          commands = commands.is_a?(Array) ? commands : [commands]
          commands = commands.compact.map(&:strip).reject(&:empty?)
          commands.each{|cmd| sh(cmd) }
        end
      end

    end
  end
end
