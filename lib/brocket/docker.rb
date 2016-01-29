require "brocket"

require 'yaml'
require 'thor'

module BRocket
  class Docker < Base
    CONFIG_LINE_SEP = "[config]".freeze
    CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s?/.freeze

    desc "config", "show configurations in Dockerfile"
    option :dockerfile, aliases: '-f', type: :string, default: "Dockerfile", desc: "Dockerfile to build"
    def config
      $stdout.puts(YAML.dump(config_hash))
    end

    desc "build", "build docker image"
    option :dockerfile, aliases: '-f', type: :string, default: "Dockerfile", desc: "Dockerfile to build"
    def build
      info("[docker build] starting")
      c = config_hash
      img_name = config_image_name(c)
      Dir.chdir(working_dir) do
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

    desc "call_before_build", "call BEFORE_BUILD callback manually"
    def call_before_build
      execute(config_hash['BEFORE_BUILD'])
    end

    desc "call_after_build", "call AFTER_BUILD callback manually"
    def call_after_build
      execute(config_hash['AFTER_BUILD'])
    end

    no_commands do
      def config_image_name(c)
        img_name = (c['IMAGE_NAME'] || '').strip
        error "No IMAGE_NAME found in Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in Dockerfile" if img_name.empty?
        img_name
      end

      def working_dir
        dir = config_hash['WORKING_DIR']
        dir ? File.expand_path(dir, File.dirname(config_filepath)) : '.'
      end

      def config_hash
        @config_hash ||= load_config_hash
      end

      def load_config_hash
        content = read_config_file
        lines = content.lines.select{|line| line =~ CONFIG_LINE_HEADER}.
          map{|line| line.sub(CONFIG_LINE_HEADER, "")}
        return (YAML.load(lines.join("\n")) || {})
      end

      def config_filepath
        options[:dockerfile] || './Dockerfile'
      end

      def read_config_file
        unless File.readable?(config_filepath)
          raise "File not found: #{config_filepath}"
        end
        File.read(config_filepath)
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
