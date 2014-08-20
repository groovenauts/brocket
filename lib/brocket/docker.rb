require "brocket"

require 'yaml'
require 'thor'

module BRocket
  class Docker < Base
    CONFIG_LINE_SEP = "[config]".freeze
    CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s?/.freeze

    desc "config", "show configurations in Dockerfile"
    def config
      $stdout.puts(YAML.dump(config_hash))
    end

    desc "build", "build docker image"
    def build
      info("[docker build] starting")
      c = config_hash
      img_name = config_image_name(c)
      begin
        execute(c['BEFORE_BUILD'])
        version = sub(VersionFile).current
        execute("docker build -t #{img_name}:#{version} .")
        execute(c['ON_BUILD_COMPLETE'])
      rescue
        execute(c['ON_BUILD_ERROR'])
        raise
      ensure
        execute(c['AFTER_BUILD'])
      end
      success("[docker build] OK")
    end

    desc "push", "push docker image to docker hub"
    def push
      info("[docker push] starting")
      c = config_hash
      img_name = config_image_name(c)
      version = sub(VersionFile).current
      cmd = "docker push #{img_name}:#{version}"
      sh(cmd)
      success("[docker push] OK")
    end

    no_commands do
      def config_image_name(c)
        img_name = (c['IMAGE_NAME'] || '').strip
        error "No IMAGE_NAME found in Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in Dockerfile" if img_name.empty?
        img_name
      end

      def config_hash
        content = read_file
        lines = content.lines.select{|line| line =~ CONFIG_LINE_HEADER}.
          map{|line| line.sub(CONFIG_LINE_HEADER, "")}
        return (YAML.load(lines.join("\n")) || {})
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
