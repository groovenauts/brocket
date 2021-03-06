require "brocket"

require 'thor'
require 'logger_pipe'

module BRocket
  class Base < Thor
    class_option :verbose, type: :boolean, aliases: "-V"
    class_option :dryrun , type: :boolean, aliases: "-D"

    no_commands do

      def sub(klass)
        task = klass.new
        task.options = self.options
        task
      end

      def dryrun?
        options[:dryrun]
      end

      def verbose?
        options[:verbose]
      end

      def verbose(msg)
        logger.debug("\e[34m#{msg}\e[0m") if verbose?
      end

      def info(msg)
        logger.info(msg)
      end
      def success(msg)
        logger.info("\e[32m#{msg}\e[0m")
      end

      def error(msg)
        raise BuildError, msg
      end

      def logger
        BRocket.logger
      end

      def sh(cmd)
        LoggerPipe.run(logger, cmd, dry_run: dryrun?, returns: :none, logging: :both)
      end

      def sh_stdout(cmd)
        LoggerPipe.run(logger, cmd, returns: :stdout, logging: :stderr) # ignore dryrun?
      end

    end

  end
end
