require "brocket"

require 'yaml'
require 'thor'

module BRocket
  class Configurable < Base
    CONFIG_LINE_SEP = "[config]".freeze
    CONFIG_LINE_HEADER = /\A\#\s*#{Regexp.escape(CONFIG_LINE_SEP)}\s?/.freeze

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
    end
  end
end
