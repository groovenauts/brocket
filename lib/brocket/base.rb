require "brocket"

require 'thor'

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

      def opts
        @opts ||= options || {}
      end

      def dryrun?
        opts[:dryrun]
      end

      def verbose?
        opts[:verbose]
      end

      def verbose(msg)
        $stderr.puts("\e[34m#{msg}\e[0m") if verbose?
      end

      def info(msg)
        $stderr.puts(msg)
      end
      def success(msg)
        $stderr.puts("\e[32m#{msg}\e[0m")
      end

      def error(msg)
        raise BuildError, msg
      end

      def sh(cmd, &block)
        out, code = sh_with_code(cmd, &block)
        code == 0 ? out : error(out.empty? ? "Running `#{cmd}' failed. Run this command directly for more detailed output." : out)
      end

      def sh_with_code(cmd, &block)
        cmd << " 2>&1"
        verbose(cmd)
        outbuf = ''
        if dryrun?
          block.call(outbuf) if block
          ["DRYRUN", 0]
        else
          outbuf = `#{cmd}`
          if $? == 0
            block.call(outbuf) if block
          end
          [outbuf, $?]
        end
      end

    end

  end
end
