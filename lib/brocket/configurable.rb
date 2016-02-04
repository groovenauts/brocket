require "brocket"

require 'yaml'
require 'thor'
require 'pathname'

module BRocket
  class Configurable < Base
    CONFIG_LINE_SEP = "[config]".freeze
    CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s?/.freeze

    class_option :dockerfile, aliases: '-f', type: :string, default: "Dockerfile", desc: "Dockerfile to build"
    # This option is used in Brocket::Docker, but it can set via BRocket::Cli
    class_option :use_sudo_for_docker, aliases: '-S', type: :string, default: "auto", desc: "auto, true, false"

    no_commands do
      def config_image_name
        img_name = (config_hash['IMAGE_NAME'] || '').strip
        error "No IMAGE_NAME found in Dockerfile. Please add `# #{CONFIG_LINE_SEP} IMAGE_NAME: [IMAGE NAME on DockerHub]` in Dockerfile" if img_name.empty?
        img_name
      end

      def working_dir
        dir = config_hash['WORKING_DIR'] || '.'
        File.expand_path(dir, File.dirname(config_filepath))
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
        @config_filepath ||= File.expand_path(options[:dockerfile] || './Dockerfile', BRocket.user_pwd)
      end

      def config_relpath
        config_p = Pathname.new(config_filepath)
        base_p   = Pathname.new(working_dir)
        config_p.relative_path_from(base_p).to_s
      end

      def read_config_file
        unless File.readable?(config_filepath)
          error "File not found: #{config_filepath}"
        end
        File.read(config_filepath)
      end
    end
  end
end
