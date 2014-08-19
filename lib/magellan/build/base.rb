require "magellan/build"

require 'thor'
require 'fileutils'

module Magellan
  module Build
    class Base < Thor
      class_option :verbose, :type => :boolean

      no_commands do
        def fileutils
          options[:verbose] ? FileUtils::Verbose : FileUtils
        end

        def sh(cmd, &block)
          out, code = sh_with_code(cmd, &block)
          code == 0 ? out : raise(out.empty? ? "Running `#{cmd}' failed. Run this command directly for more detailed output." : out)
        end

        def sh_with_code(cmd, &block)
          cmd << " 2>&1"
          outbuf = ''
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
