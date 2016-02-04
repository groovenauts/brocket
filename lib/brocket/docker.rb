require "brocket"

require 'yaml'
require 'thor'

module BRocket
  class Docker < Configurable

    desc "config", "show configurations in Dockerfile"
    def config
      $stdout.puts(YAML.dump(config_hash))
    end

    desc "build", "build docker image"
    def build
      info("[docker build] starting")
      c = config_hash
      Dir.chdir(working_dir) do
        begin
          execute(c['BEFORE_BUILD'])
          cmd = build_build_command
          execute(cmd)
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
      cmd = build_push_command
      sh(cmd)
      success("[docker push] OK")
    end

    desc "call_before_build", "call BEFORE_BUILD callback manually"
    def call_before_build
      Dir.chdir(working_dir) do
        execute(config_hash['BEFORE_BUILD'])
      end
    end

    desc "call_after_build", "call AFTER_BUILD callback manually"
    def call_after_build
      Dir.chdir(working_dir) do
        execute(config_hash['AFTER_BUILD'])
      end
    end

    no_commands do
      def build_build_command
        img_name = config_image_name
        version = sub(VersionFile).current
        cmd = sudo("docker build -t #{img_name}:#{version}")
        if options[:dockerfile]
          fp = config_relpath
          unless fp == "Dockerfile"
            cmd << ' -f ' << config_relpath
          end
        end
        cmd << ' .'
        return cmd
      end

      def build_push_command
        registry = config_hash['DOCKER_PUSH_REGISTRY']
        username = config_hash['DOCKER_PUSH_USERNAME']
        extra_tag = config_hash['DOCKER_PUSH_EXTRA_TAG']
        img_name = [registry, username, config_image_name].compact.join('/')
        version = sub(VersionFile).current
        build_cmd = config_hash['DOCKER_PUSH_COMMAND'] || 'docker push'
        cmd = [
          (registry || username) ?
            sudo("docker tag -f #{config_image_name}:#{version} #{img_name}:#{version}") : nil,
          (registry || username) && extra_tag ?
            sudo("docker tag -f #{config_image_name}:#{version} #{img_name}:#{extra_tag}") : nil,
          sudo("#{build_cmd} #{img_name}:#{version}"),
          extra_tag ?
            sudo("#{build_cmd} #{img_name}:#{extra_tag}") : nil,
        ].compact.join(' && ')
        return cmd
      end

      def execute(commands)
        return unless commands
        commands = commands.is_a?(Array) ? commands : [commands]
        commands = commands.compact.map(&:strip).reject(&:empty?)
        commands.each{|cmd| sh(cmd) }
      end

      def sudo(cmd)
        if @sudo_required.nil?
          @sudo_required =
            case options[:use_sudo_for_docker]
            when /auto/i then !system("docker ps >/dev/null 2>/dev/null")
            when /true/i then true
            else false
            end
        end
        @sudo_required ? "sudo #{cmd}" : cmd
      end
    end

  end
end
