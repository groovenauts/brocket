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
      end

    end
  end
end
