require "brocket"

require 'thor'

module BRocket
  class Base < Thor
    class_option :verbose, :type => :boolean
    class_option :dryrun , :type => :boolean

    no_commands do

      def dryrun?
        (options || {})[:dryrun]
      end

      def verbose?
        (options || {})[:verbose]
      end

      def chdir(dir, &block)
        dir ||= "."
        verbose("cd #{dir}")
        Dir.chdir(dir, &block)
        verbose("cd #{Dir.pwd}")
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
